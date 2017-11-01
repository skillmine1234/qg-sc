# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sc_backend do
    sequence(:code) {|n| "9" + "%03i" % "#{n}" }
    do_auto_shutdown "Y"
    max_consecutive_failures 1
    min_consecutive_success 2
    max_window_failures 3
    window_in_mins 6
    do_auto_start "N"
    min_window_success 4
    alert_email_to "def@ruby.com"
    approval_status "U"
    last_action "C"
    use_proxy "Y"
  end
end