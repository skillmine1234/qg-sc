# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sc_backend_stat do
    code {Factory(:sc_backend).code}
    consecutive_failure_cnt 1
    consecutive_success_cnt 1
    window_started_at "2016-10-19 15:12:44"
    window_ends_at "2016-10-19 17:12:44"
    window_failure_cnt 1
    window_success_cnt 1
    auditable_type "ScBackendStat"
    auditable_id 1
    last_status_change_id 1
  end
end