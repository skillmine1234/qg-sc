FactoryGirl.define do
  factory :sc_service do
    sequence(:code) {|n| "#{n}" }
    sequence(:name) {|n| "#{n}" }
  end
end
