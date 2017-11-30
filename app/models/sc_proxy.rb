class ScProxy < ActiveRecord::Base
  include Approval2::ModelAdditions

  belongs_to :created_user, :foreign_key =>'created_by', :class_name => 'User'
  belongs_to :updated_user, :foreign_key =>'updated_by', :class_name => 'User'

  validates_presence_of :url, :is_enabled
  validates_presence_of :password, if: "username.present?"
  validates_uniqueness_of :url, scope: :approval_status
  validates :url, format: {with: URI.regexp, :message => 'Invalid format, expected format is : https://example.com' }, length: { maximum: 100 }, allow_blank: true
  validates :password, length: { maximum: 50 }, allow_blank: true
  validates :username, format: { with: /\A[a-z|A-Z|0-9|\.|\_]+\z/, :message => 'Invalid format, expected format is : {[a-z|A-Z|0-9|\.|\_]}' }, length: { maximum: 100 }, allow_blank: true

  before_save :encrypt_values
  after_save :decrypt_values
  after_find :decrypt_values

  private

  def decrypt_values
    self.password = DecPassGenerator.new(password,ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET']).generate_decrypted_data if password.present?
  end

  def encrypt_values
    self.password = EncPassGenerator.new(self.password, ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET']).generate_encrypted_password unless password.to_s.empty?
  end
end