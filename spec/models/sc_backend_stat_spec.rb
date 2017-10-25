require 'spec_helper'

describe ScBackendStat do
  context 'association' do
    it { should belong_to(:sc_backend) }
  end

  context 'validation' do
    [:code, :consecutive_failure_cnt, :consecutive_success_cnt, :window_started_at, :window_ends_at,
     :window_failure_cnt, :window_success_cnt, :auditable_type, :auditable_id].each do |att|
      it { should validate_presence_of(att) }
    end

    it do
      sc_backend_stat = Factory(:sc_backend_stat)
      should validate_length_of(:code).is_at_most(20)
      should validate_length_of(:step_name).is_at_most(100)
      should validate_length_of(:last_alert_email_ref).is_at_most(64)
    end

    it do 
      sc_backend_stat = Factory(:sc_backend_stat)
      should validate_uniqueness_of(:code)
    end

    it "should return error if code is already taken" do
      sc_backend_stat1 = Factory(:sc_backend_stat, :code => "9933")
      sc_backend_stat2 = Factory.build(:sc_backend_stat, :code => "9933")
      sc_backend_stat2.should_not be_valid
      sc_backend_stat2.errors_on(:code).should == ["has already been taken"]
    end
  end
end
