class ScBackend < ActiveRecord::Base
  include Approval2::ModelAdditions

  belongs_to :created_user, :foreign_key =>'created_by', :class_name => 'User'
  belongs_to :updated_user, :foreign_key =>'updated_by', :class_name => 'User'

  has_one :sc_backend_stat, :foreign_key => "code", :primary_key => 'code'
  has_one :sc_backend_status, :foreign_key => "code", :primary_key => 'code'
  has_many :sc_backend_status_changes, :foreign_key => "code", :primary_key => 'code'
  accepts_nested_attributes_for :sc_backend_status_changes

  validates_presence_of :code, :do_auto_shutdown, :max_consecutive_failures, :window_in_mins, :max_window_failures, 
                        :do_auto_start, :min_consecutive_success, :min_window_success, :use_proxy
  validates_uniqueness_of :code, :scope => :approval_status

  validates :code, length: { maximum: 20 }
  validates :do_auto_shutdown, length: { minimum: 1, maximum: 1 }
  validates :window_in_mins, length: { minimum: 1, maximum: 2 }
  validates_inclusion_of :window_in_mins, :in => [1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60], :message => "Allowed Values: 1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60"
  validates :do_auto_start, length: { minimum: 1, maximum: 1 }

  validates :max_consecutive_failures, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :max_window_failures, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :min_consecutive_success, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :min_window_success, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :first_requery_after, :requery_interval, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :url, format: { with: URI.regexp , :message => 'Please enter a valid url, Eg: http://example.com'}, length: { maximum: 100 }, :allow_blank => true

  validate :check_max_consecutive_failures
  validate :check_min_consecutive_success
  validate :check_max_window_failures
  validate :check_email_addresses

  validates_presence_of :http_password, if: "http_username.present?"
  validates_absence_of :http_password, if: "http_username.blank?"
  validates :http_password, length: { maximum: 50 }, allow_blank: true
  validates :http_username, format: { with: /\A[a-z|A-Z|0-9|\.|\_]+\z/, :message => 'Invalid format, expected format is : {[a-z|A-Z|0-9|\.|\_]}' }, length: { maximum: 100 }, allow_blank: true

  before_save :encrypt_values
  after_save :decrypt_values
  after_find :decrypt_values

  def check_max_consecutive_failures
    if (self.max_consecutive_failures.present? and self.min_consecutive_success.present?)
      errors[:max_consecutive_failures] << "should be less than Minimum Consecutive Success" if (self.max_consecutive_failures > self.min_consecutive_success)
    end
    if (self.max_consecutive_failures.present? and self.max_window_failures.present?)
      errors[:max_consecutive_failures] << "should be less than Maximum Window Failures" if (self.max_consecutive_failures > self.max_window_failures)
    end
    if (self.max_consecutive_failures.present? and self.min_window_success.present?)
      errors[:max_consecutive_failures] << "should be less than Minimum Window Success" if (self.max_consecutive_failures > self.min_window_success)
    end
  end

  def check_min_consecutive_success
    if (self.min_consecutive_success.present? and self.max_window_failures.present?)
      errors[:min_consecutive_success] << "should be less than Maximum Window Failures" if (self.min_consecutive_success > self.max_window_failures)
    end
    if (self.min_consecutive_success.present? and self.min_window_success.present?)
      errors[:min_consecutive_success] << "should be less than Minimum Window Success" if (self.min_consecutive_success > self.min_window_success)
    end
  end

  def check_max_window_failures
    if (self.max_window_failures.present? and self.min_window_success.present?)
      errors[:max_window_failures] << "should be less than Minimum Window Success" if (self.max_window_failures > self.min_window_success)
    end
  end

  def check_email_addresses
    ["alert_email_to"].each do |email_id|
      invalid_ids = []
      value = self.send(email_id)
      unless value.nil?
        value.split(/;\s*/).each do |email| 
          unless email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
            invalid_ids << email
          end
        end
      end
      errors.add(email_id.to_sym, "is invalid, expected format is abc@def.com") unless invalid_ids.empty?
    end
  end
  
  private

  def decrypt_values
    self.http_password = DecPassGenerator.new(http_password,ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET']).generate_decrypted_data if http_password.present?
  end

  def encrypt_values
    self.http_password = EncPassGenerator.new(self.http_password, ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET']).generate_encrypted_password unless http_password.to_s.empty?
  end
end
