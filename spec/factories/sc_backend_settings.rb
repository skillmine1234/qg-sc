# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sc_backend_setting do
    backend_code 'MyString'
    service_code 'MyString'
    sequence(:app_id) {|n| "%04i" % "#{n}"}
    created_by {Factory(:user).id}
    updated_by {Factory(:user).id}
    lock_version 1
    approval_status "U"
    last_action "C"
    approved_version 1
  end
end