# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sc_fault_code do
    sequence(:fault_code) {|n| "%04i" % "#{n}"}
    fault_reason "MyString"
    fault_kind 'B'
    occurs_when "MyString"
    remedial_action 'MySrting'
  end
end