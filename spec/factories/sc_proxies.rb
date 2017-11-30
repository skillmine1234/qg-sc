FactoryGirl.define do
  factory :sc_proxy do
    url 'https://example.com'
    lock_version 0
    approval_status 'U'
  end
end
