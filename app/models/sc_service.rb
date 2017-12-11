class ScService < ActiveRecord::Base
  include Approval2::ModelAdditions

  belongs_to :created_user, :foreign_key =>'created_by', :class_name => 'User'
  belongs_to :updated_user, :foreign_key =>'updated_by', :class_name => 'User'

  validates_presence_of :code, :name, :use_proxy

  has_many :incoming_file_types
  has_many :outgoing_file_types

  validates_presence_of :http_password, if: "http_username.present?"
  validates_absence_of :http_password, if: "http_username.blank?"
  validates_uniqueness_of :code, scope: :approval_status
  validates_uniqueness_of :name, scope: :approval_status
  validates :url, format: {with: URI.regexp, :message => 'Invalid format, expected format is : https://example.com' }, length: { maximum: 100 }, allow_blank: true
  validates :http_password, length: { maximum: 50 }, allow_blank: true
  validates :http_username, format: { with: /\A[a-z|A-Z|0-9|\.|\_]+\z/, :message => 'Invalid format, expected format is : {[a-z|A-Z|0-9|\.|\_]}' }, length: { maximum: 100 }, allow_blank: true

  before_save :encrypt_values
  after_save :decrypt_values
  after_find :decrypt_values

  def has_auto_upload?
    auto_uploads = incoming_file_types.where("auto_upload=?",'N')
    auto_uploads.empty? ? true : false
  end

  private

  def decrypt_values
    self.http_password = DecPassGenerator.new(http_password,ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET']).generate_decrypted_data if http_password.present?
  end

  def encrypt_values
    self.http_password = EncPassGenerator.new(self.http_password, ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET']).generate_encrypted_password unless http_password.to_s.empty?
  end
end
