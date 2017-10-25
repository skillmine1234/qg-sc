require 'spec_helper'

describe ScBackendResponseCode do

  context 'association' do
    it { should belong_to(:created_user) }
    it { should belong_to(:updated_user) }
  end

  context "validation" do
    [:sc_backend_code, :response_code, :fault_code, :is_enabled].each do |att|
      it { should validate_presence_of(att) }
    end
  end

  context "default_scope" do 
    it "should only return 'A' records by default" do 
      sc_backend_response_code1 = Factory(:sc_backend_response_code, :approval_status => 'A') 
      sc_backend_response_code2 = Factory(:sc_backend_response_code, :response_code => 'MyString')
      ScBackendResponseCode.all.should == [sc_backend_response_code1]
      sc_backend_response_code2.approval_status = 'A'
      sc_backend_response_code2.save
      ScBackendResponseCode.all.should == [sc_backend_response_code1,sc_backend_response_code2]
    end
  end    

  context "unapproved_records" do 
    it "oncreate: should create unapproved_record if the approval_status is 'U'" do
      sc_backend_response_code = Factory(:sc_backend_response_code)
      sc_backend_response_code.reload
      sc_backend_response_code.unapproved_record_entry.should_not be_nil
    end

    it "oncreate: should not create unapproved_record if the approval_status is 'A'" do
      sc_backend_response_code = Factory(:sc_backend_response_code, :approval_status => 'A')
      sc_backend_response_code.unapproved_record_entry.should be_nil
    end

    it "onupdate: should not remove unapproved_record if approval_status did not change from U to A" do
      sc_backend_response_code = Factory(:sc_backend_response_code)
      sc_backend_response_code.reload
      sc_backend_response_code.unapproved_record_entry.should_not be_nil
      record = sc_backend_response_code.unapproved_record_entry
      # we are editing the U record, before it is approved
      sc_backend_response_code.response_code = 'Foo123'
      sc_backend_response_code.save
      sc_backend_response_code.reload
      sc_backend_response_code.unapproved_record_entry.should == record
    end

    it "onupdate: should remove unapproved_record if the approval_status changed from 'U' to 'A' (approval)" do
      sc_backend_response_code = Factory(:sc_backend_response_code)
      sc_backend_response_code.reload
      sc_backend_response_code.unapproved_record_entry.should_not be_nil
      # the approval process changes the approval_status from U to A for a newly edited record
      sc_backend_response_code.approval_status = 'A'
      sc_backend_response_code.save
      sc_backend_response_code.reload
      sc_backend_response_code.unapproved_record_entry.should be_nil
    end

    it "ondestroy: should remove unapproved_record if the record with approval_status 'U' was destroyed (approval) " do
      sc_backend_response_code = Factory(:sc_backend_response_code)
      sc_backend_response_code.reload
      sc_backend_response_code.unapproved_record_entry.should_not be_nil
      record = sc_backend_response_code.unapproved_record_entry
      # the approval process destroys the U record, for an edited record 
      sc_backend_response_code.destroy
      UnapprovedRecord.find_by_id(record.id).should be_nil
    end
  end

  context "approve" do 
    it "should approve unapproved_record" do 
      sc_backend_response_code = Factory(:sc_backend_response_code, :approval_status => 'U')
      sc_backend_response_code.approve.save.should == true
      sc_backend_response_code.approval_status.should == 'A'
    end

    it "should return error when trying to approve unmatched version" do 
      sc_backend_response_code = Factory(:sc_backend_response_code, :approval_status => 'A')
      sc_backend_response_code1 = Factory(:sc_backend_response_code, :approval_status => 'U', :approved_id => sc_backend_response_code.id, :approved_version => 6)
      sc_backend_response_code1.approve.should == "The record version is different from that of the approved version" 
    end
  end

  context "enable_approve_button?" do 
    it "should return true if approval_status is 'U' else false" do 
      sc_backend_response_code1 = Factory(:sc_backend_response_code, :approval_status => 'A')
      sc_backend_response_code2 = Factory(:sc_backend_response_code, :approval_status => 'U')
      sc_backend_response_code1.enable_approve_button?.should == false
      sc_backend_response_code2.enable_approve_button?.should == true
    end
  end
  
  context 'presence_of_codes' do
    it 'should validate presence of fault_code and sc_backend_code' do
      sc_backend_response_code1 = Factory.build(:sc_backend_response_code, sc_backend_code: '123')
      sc_backend_response_code1.errors_on(:sc_backend_code).should == ['is invalid']
      
      sc_backend_response_code2 = Factory.build(:sc_backend_response_code, fault_code: '123')
      sc_backend_response_code2.errors_on(:fault_code).should == ['is invalid']
      
      sc_backend = Factory(:sc_backend, approval_status: 'A')
      sc_fault_code = Factory(:sc_fault_code)
      
      sc_backend_response_code1 = Factory.build(:sc_backend_response_code, sc_backend_code: sc_backend.code)
      sc_backend_response_code1.errors_on(:sc_backend_code).should == []
      
      sc_backend_response_code2 = Factory.build(:sc_backend_response_code, fault_code: sc_fault_code.fault_code)
      sc_backend_response_code2.errors_on(:fault_code).should == []
    end
  end
end
