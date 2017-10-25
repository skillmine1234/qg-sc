FactoryGirl.define do
  factory :sc_job do
    sequence(:code) {|n| "#{n}" }
    sc_service_id { Factory(:sc_service).id }
  end
end
