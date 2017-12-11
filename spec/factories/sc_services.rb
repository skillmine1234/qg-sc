FactoryGirl.define do
  factory :sc_service do
    sequence(:code) {|n| "#{n}" }
    sequence(:name) {|n| "#{n}" }
    use_proxy 'Y'
    url 'https://example.com'
    lock_version 0
    approval_status 'U'
  end
end
