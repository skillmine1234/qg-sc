class ScBackendStat < ActiveRecord::Base
  validates_presence_of :code, :consecutive_failure_cnt, :consecutive_success_cnt, :window_started_at, :window_ends_at,
                        :window_failure_cnt, :window_success_cnt, :auditable_type, :auditable_id
  validates_uniqueness_of :code

  validates :code, length: { maximum: 20 }
  validates :step_name, length: { maximum: 100 }
  validates :last_alert_email_ref, length: { maximum: 64 }
  
  belongs_to :sc_backend, :foreign_key => 'code', :primary_key => 'code'
end
