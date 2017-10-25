class ScJob < ActiveRecord::Base
  belongs_to :sc_service
  
  attr_readonly :code, :sc_service_id, :run_at_hour, :last_run_at, :last_run_by, :run_every_hour
end