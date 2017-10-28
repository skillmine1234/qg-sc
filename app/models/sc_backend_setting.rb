class ScBackendSetting < ActiveRecord::Base
  include Approval2::ModelAdditions
  
  TOTAL_SETTINGS_COUNT = 10
  include Setting

  belongs_to :created_user, :foreign_key =>'created_by', :class_name => 'User'
  belongs_to :updated_user, :foreign_key =>'updated_by', :class_name => 'User'
  
  attr_accessor :needs_app_code

  after_initialize :set_is_std
  
  validates_presence_of :backend_code, :service_code

  validates_presence_of :app_id, if: "is_std == 'N'"
  validates_absence_of :app_id, if: "is_std == 'Y'", message: "must be blank for standard settings"

  validates_uniqueness_of :backend_code, scope: [:service_code, :app_id, :approval_status], if: "app_id.present?"
  
  validates :backend_code, :service_code, format: {with: /\A[a-z|A-Z|0-9|\.|\-]+\z/, :message => 'Invalid format, expected format is : {[a-z|A-Z|0-9|\.|\-]}' }, length: { maximum: 50 }
  validates :app_id, format: {with: /\A[a-z|A-Z|0-9|\.|\-]+\z/, :message => 'Invalid format, expected format is : {[a-z|A-Z|0-9|\.|\-]}' }, length: { maximum: 50 }, allow_blank: true
    
  validate :validate_standard_values, if: "is_std=='Y' && self.approved_record.present?"
  
  private
  
  def set_is_std
    self.is_std = 'N' if self.is_std != 'Y'
  end
  
  def validate_standard_values
    errors[:base] << "Backend Code, Service Code and Enabled? can't be modified for standard settings" if (self.approved_record.backend_code != backend_code || self.approved_record.service_code != service_code || self.approved_record.is_enabled != is_enabled)
  end

  def self.options_for_service_code(backend_code)
    ScBackendSetting.where(app_id: nil, backend_code: backend_code).pluck(:service_code)
  end

  def self.options_for_backend_code
    ScBackendSetting.where(app_id: nil).pluck('distinct backend_code')
  end
  
end