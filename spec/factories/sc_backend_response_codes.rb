# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sc_backend_response_code do
    is_enabled "Y"
    sc_backend_code {Factory(:sc_backend, approval_status: 'A').code}
    response_code "MyString"
    fault_code {Factory(:sc_fault_code).fault_code}
    created_by {Factory(:user).id}
    updated_by {Factory(:user).id}
    lock_version 1
    approval_status "U"
    last_action "C"
    approved_version 1
  end
end