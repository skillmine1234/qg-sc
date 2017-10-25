# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sc_backend_status_change do
    sequence(:code) {|n| "9" + "%03i" % "#{n}" }
    new_status 'U'
    remarks 'MyString'
    created_by 1
  end
end