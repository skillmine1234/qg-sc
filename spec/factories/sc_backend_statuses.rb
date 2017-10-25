# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sc_backend_status do
    code {Factory(:sc_backend).code}
    status 'U'
  end
end