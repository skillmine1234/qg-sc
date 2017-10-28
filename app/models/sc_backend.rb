class ScBackend < ActiveRecord::Base
  include Approval2::ModelAdditions

  belongs_to :created_user, :foreign_key =>'created_by', :class_name => 'User'
  belongs_to :updated_user, :foreign_key =>'updated_by', :class_name => 'User'

  has_one :sc_backend_stat, :foreign_key => "code", :primary_key => 'code'
  has_one :sc_backend_status, :foreign_key => "code", :primary_key => 'code'
  has_many :sc_backend_status_changes, :foreign_key => "code", :primary_key => 'code'
  accepts_nested_attributes_for :sc_backend_status_changes

  validates_presence_of :code, :do_auto_shutdown, :max_consecutive_failures, :window_in_mins, :max_window_failures, 
                        :do_auto_start, :min_consecutive_success, :min_window_success
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
  validates :urls, format: { with: URI.regexp , :message => 'Please enter a valid url, Eg: http://example.com'}
  
  validate :check_max_consecutive_failures
  validate :check_min_consecutive_success
  validate :check_max_window_failures
  validate :check_email_addresses

  def check_max_consecutive_failures
    unless (self.max_consecutive_failures.nil? and self.min_consecutive_success.nil?)
      errors[:max_consecutive_failures] << "should be less than Minimum Consecutive Success" if (self.max_consecutive_failures > self.min_consecutive_success)
    end
    unless (self.max_consecutive_failures.nil? and self.max_window_failures.nil?)
      errors[:max_consecutive_failures] << "should be less than Maximum Window Failures" if (self.max_consecutive_failures > self.max_window_failures)
    end
    unless (self.max_consecutive_failures.nil? and self.min_window_success.nil?)
      errors[:max_consecutive_failures] << "should be less than Minimum Window Success" if (self.max_consecutive_failures > self.min_window_success)
    end
  end

  def check_min_consecutive_success
    unless (self.min_consecutive_success.nil? and self.max_window_failures.nil?)
      errors[:min_consecutive_success] << "should be less than Maximum Window Failures" if (self.min_consecutive_success > self.max_window_failures)
    end
    unless (self.min_consecutive_success.nil? and self.min_window_success.nil?)
      errors[:min_consecutive_success] << "should be less than Minimum Window Success" if (self.min_consecutive_success > self.min_window_success)
    end
  end

  def check_max_window_failures
    unless (self.max_window_failures.nil? and self.min_window_success.nil?)
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
end
