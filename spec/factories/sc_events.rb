# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sc_event do
    sequence(:event) {|n| "%03i" % "#{n}"}
  end
end