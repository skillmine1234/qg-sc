class ScBackendResponseCode < ActiveRecord::Base
  include Approval2::ModelAdditions
  
  attr_accessor :fault_reason
  
  belongs_to :created_user, :foreign_key =>'created_by', :class_name => 'User'
  belongs_to :updated_user, :foreign_key =>'updated_by', :class_name => 'User'
    
  has_one :sc_backend, :class_name => 'ScBackend', :primary_key => 'sc_backend_code', :foreign_key => 'code'
  has_one :sc_fault_code, :class_name => 'ScFaultCode', :primary_key => 'fault_code', :foreign_key => 'fault_code'
  
  validates_presence_of :sc_backend_code, :response_code, :fault_code, :is_enabled
  
  validates_uniqueness_of :sc_backend_code, scope: [:response_code, :approval_status]
  
  validate :presence_of_codes
  
  def presence_of_codes
    errors.add(:sc_backend_code) if sc_backend.nil?
    errors.add(:fault_code) if sc_fault_code.nil?
  end
end