require 'spec_helper'

describe ScJob do
  context 'association' do
    it { should belong_to(:sc_service) }
  end
  
  context 'readonly fields' do
    it 'should allow update of non readonly fields' do
      sc_job = Factory(:sc_job)
      sc_job.update_column(:run_now, 'N').should == true
      sc_job.update_column(:paused, 'N').should == true
    end

    it 'should not allow update of readonly fields' do
      sc_job = Factory(:sc_job)
      
      lambda {sc_job.update_column(:code, 'A')}.should raise_error(ActiveRecord::ActiveRecordError)
      lambda {sc_job.update_column(:sc_service_id, 2)}.should raise_error(ActiveRecord::ActiveRecordError)
      lambda {sc_job.update_column(:run_at_hour, 10)}.should raise_error(ActiveRecord::ActiveRecordError)
      lambda {sc_job.update_column(:last_run_at, Time.now)}.should raise_error(ActiveRecord::ActiveRecordError)
      lambda {sc_job.update_column(:last_run_by, '1')}.should raise_error(ActiveRecord::ActiveRecordError)
    end
  end
end