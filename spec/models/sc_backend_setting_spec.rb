require 'spec_helper'

describe ScBackendSetting do

  context 'association' do
    it { should belong_to(:created_user) }
    it { should belong_to(:updated_user) }
  end

  context "validation" do
    [:backend_code, :service_code].each do |att|
      it { should validate_presence_of(att) }
    end
    
    [:backend_code, :service_code, :app_id].each do |att|
      it { should validate_length_of(att).is_at_most(50) }
    end
    
    it do 
      sc_backend_setting = Factory(:sc_backend_setting, :approval_status => 'A')
      should validate_uniqueness_of(:backend_code).scoped_to(:service_code, :app_id, :approval_status)
    end
    
    context "format" do
      context "backend_code, service_code, app_id" do 
        it "should accept value matching the format" do
          [:backend_code, :service_code, :app_id].each do |att|
            should allow_value('username').for(att)
            should allow_value('user-name').for(att)
            should allow_value('user.123').for(att)
          end
        end

        it "should not accept value which does not match the format" do
          [:backend_code, :service_code, :app_id].each do |att|
            should_not allow_value('user@name').for(att)
            should_not allow_value('user@123*^').for(att)
          end
        end
      end
    end
    
    it "should validate presence of app_id if its a new record or when an approved record with app_id not null is edited" do
      sc_backend_setting1 = Factory.build(:sc_backend_setting, app_id: nil, is_std: 'N')
      sc_backend_setting1.errors_on(:app_id).should == ["can't be blank"]

      sc_backend_setting2 = Factory(:sc_backend_setting, :approval_status => 'A', app_id: '12345', is_std: 'N')
      sc_backend_setting3 = Factory.build(:sc_backend_setting, :approval_status => 'U', :approved_id => sc_backend_setting2.id, app_id: '12345')
      sc_backend_setting3.errors_on(:app_id).should == []

      sc_backend_setting3 = Factory.build(:sc_backend_setting, app_id: '12314', is_std: 'Y')
      sc_backend_setting3.errors_on(:app_id).should == ["must be blank for standard settings"]
    end
    
    it "should validate that the backend_code and service code are not modified on edit of standard settings" do
      sc_backend_setting1 = Factory(:sc_backend_setting, :approval_status => 'A', app_id: nil, is_std: 'Y', backend_code: 'B123', service_code: 'S123')
      sc_backend_setting2 = Factory.build(:sc_backend_setting, :approval_status => 'U', :approved_id => sc_backend_setting1.id, app_id: nil, backend_code: 'B111', is_std: 'Y')
      sc_backend_setting2.errors_on(:base).should == ["Backend Code, Service Code and Enabled? can't be modified for standard settings"]
      
      sc_backend_setting3 = Factory(:sc_backend_setting, :approval_status => 'A', app_id: nil, is_std: 'Y', backend_code: 'B901', service_code: 'S111')
      sc_backend_setting4 = Factory.build(:sc_backend_setting, :approval_status => 'U', :approved_id => sc_backend_setting3.id, app_id: nil, service_code: 'B111', is_std: 'Y')
      sc_backend_setting4.errors_on(:base).should == ["Backend Code, Service Code and Enabled? can't be modified for standard settings"]
      
      sc_backend_setting5 = Factory(:sc_backend_setting, :approval_status => 'A', app_id: nil, is_std: 'Y', backend_code: 'B902', service_code: 'S222', is_enabled: 'Y')
      sc_backend_setting6 = Factory.build(:sc_backend_setting, :approval_status => 'U', :approved_id => sc_backend_setting5.id, app_id: nil, backend_code: 'B902', service_code: 'S222', is_std: 'Y', is_enabled: 'N')
      sc_backend_setting6.errors_on(:base).should == ["Backend Code, Service Code and Enabled? can't be modified for standard settings"]
    end
    
    it "should validate presence of setting names" do
      sc_backend_setting = Factory.build(:sc_backend_setting, setting1_name: nil, setting2_name: 'setting2')
      sc_backend_setting.save.should == false
      sc_backend_setting.errors_on(:setting1_name).should == ["can't be blank when Setting2 name is present"]
    end

    it "should validate the setting values" do
      sc_backend_setting = Factory.build(:sc_backend_setting, setting1_name: 'name1', setting1_type: 'text', setting1_value: nil)
      sc_backend_setting.save.should == false
      sc_backend_setting.errors_on('name1').should == ["can't be blank"]

      sc_backend_setting = Factory.build(:sc_backend_setting, setting1_name: 'name1', setting1_type: 'text', setting1_value: 'text')
      sc_backend_setting.save.should == true
      sc_backend_setting.errors_on('name1').should == []

      sc_backend_setting = Factory.build(:sc_backend_setting, setting1_name: 'name1', setting1_type: 'number', setting1_value: 'TEXT')
      sc_backend_setting.save.should == false
      sc_backend_setting.errors_on('name1').should == ["should include only digits"]

      sc_backend_setting = Factory.build(:sc_backend_setting, setting1_name: 'name1', setting1_type: 'number', setting1_value: '1234')
      sc_backend_setting.save.should == true
      sc_backend_setting.errors_on('name1').should == []

      sc_backend_setting = Factory.build(:sc_backend_setting, setting1_name: 'name1', setting1_type: 'text', setting1_value: 'yterqweytweuyqtweyqteyqtwerqwyertqweuryqwieuryqwerehquqwkjhequeuqeyuqjwhegruqywerqwjkeqjwehqjweqjhwegqhwe')
      sc_backend_setting.save.should == false
      sc_backend_setting.errors_on('name1').should == ["is longer than maximum (100)"]

      sc_backend_setting = Factory.build(:sc_backend_setting, setting1_name: 'name1', setting1_type: 'date', setting1_value: '2014:12:12')
      sc_backend_setting.save.should == false
      sc_backend_setting.errors_on('name1').should == ["invalid format, the correct format is yyyy-mm-dd", "is not a date"]

      sc_backend_setting = Factory.build(:sc_backend_setting, setting1_name: 'name1', setting1_type: 'date', setting1_value: '2016-12-12')
      sc_backend_setting.save.should == true
      sc_backend_setting.errors_on('name1').should == []
    end
  end

  context "default_scope" do 
    it "should only return 'A' records by default" do 
      sc_backend_setting1 = Factory(:sc_backend_setting, :approval_status => 'A')
      sc_backend_setting2 = Factory(:sc_backend_setting, :backend_code => 'MyString')
      ScBackendSetting.all.should == [sc_backend_setting1]
      sc_backend_setting2.approval_status = 'A'
      sc_backend_setting2.save
      ScBackendSetting.all.should == [sc_backend_setting1,sc_backend_setting2]
    end
  end    

  context "unapproved_records" do 
    it "oncreate: should create unapproved_record if the approval_status is 'U'" do
      sc_backend_setting = Factory(:sc_backend_setting)
      sc_backend_setting.reload
      sc_backend_setting.unapproved_record_entry.should_not be_nil
    end

    it "oncreate: should not create unapproved_record if the approval_status is 'A'" do
      sc_backend_setting = Factory(:sc_backend_setting, :approval_status => 'A')
      sc_backend_setting.unapproved_record_entry.should be_nil
    end

    it "onupdate: should not remove unapproved_record if approval_status did not change from U to A" do
      sc_backend_setting = Factory(:sc_backend_setting)
      sc_backend_setting.reload
      sc_backend_setting.unapproved_record_entry.should_not be_nil
      record = sc_backend_setting.unapproved_record_entry
      # we are editing the U record, before it is approved
      sc_backend_setting.backend_code = 'Foo123'
      sc_backend_setting.save
      sc_backend_setting.reload
      sc_backend_setting.unapproved_record_entry.should == record
    end

    it "onupdate: should remove unapproved_record if the approval_status changed from 'U' to 'A' (approval)" do
      sc_backend_setting = Factory(:sc_backend_setting)
      sc_backend_setting.reload
      sc_backend_setting.unapproved_record_entry.should_not be_nil
      # the approval process changes the approval_status from U to A for a newly edited record
      sc_backend_setting.approval_status = 'A'
      sc_backend_setting.save
      sc_backend_setting.reload
      sc_backend_setting.unapproved_record_entry.should be_nil
    end

    it "ondestroy: should remove unapproved_record if the record with approval_status 'U' was destroyed (approval) " do
      sc_backend_setting = Factory(:sc_backend_setting)
      sc_backend_setting.reload
      sc_backend_setting.unapproved_record_entry.should_not be_nil
      record = sc_backend_setting.unapproved_record_entry
      # the approval process destroys the U record, for an edited record 
      sc_backend_setting.destroy
      UnapprovedRecord.find_by_id(record.id).should be_nil
    end
  end

  context "approve" do 
    it "should approve unapproved_record" do 
      sc_backend_setting = Factory(:sc_backend_setting, :approval_status => 'U')
      sc_backend_setting.approve.save.should == true
      sc_backend_setting.approval_status.should == 'A'
    end

    it "should return error when trying to approve unmatched version" do 
      sc_backend_setting = Factory(:sc_backend_setting, :approval_status => 'A')
      sc_backend_setting1 = Factory(:sc_backend_setting, :approval_status => 'U', :approved_id => sc_backend_setting.id, :approved_version => 6)
      sc_backend_setting1.approve.should == "The record version is different from that of the approved version" 
    end
  end

  context "enable_approve_button?" do 
    it "should return true if approval_status is 'U' else false" do 
      sc_backend_setting1 = Factory(:sc_backend_setting, :approval_status => 'A')
      sc_backend_setting2 = Factory(:sc_backend_setting, :approval_status => 'U')
      sc_backend_setting1.enable_approve_button?.should == false
      sc_backend_setting2.enable_approve_button?.should == true
    end
  end
  
  context "set_settings_cnt" do
    it "should set counts of settings" do
      sc_backend_setting = Factory(:sc_backend_setting, setting1_name: 'set1', setting1_type: 'number', setting1_value: '1')
      sc_backend_setting.settings_cnt.should == 1
    end
  end
end
