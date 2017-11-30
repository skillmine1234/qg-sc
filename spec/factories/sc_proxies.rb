FactoryGirl.define do
  factory :sc_proxy do
    sc_backend_code { Factory(:sc_backend, approval_status: 'A').code }
    url 'https://example.com'
    lock_version 0
    approval_status 'U'
  end
end
