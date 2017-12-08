require 'spec_helper'

describe ScService do
  context 'association' do
    it { should belong_to(:created_user) }
    it { should belong_to(:updated_user) }
    it { should have_one(:unapproved_record_entry) }
    it { should belong_to(:approved_record) }
  end
  
  context 'validation' do
    [:code, :name].each do |att|
      it { should validate_presence_of(att) }
    end

    it do
      sc_service = Factory(:sc_service, code: 'FUNDSTRANSFER', name: 'FundsTransferService', approval_status: 'A')
      should validate_uniqueness_of(:code).scoped_to(:approval_status)
      should validate_uniqueness_of(:name).scoped_to(:approval_status)
    end
    
    it "should validate_unapproved_record" do 
      sc_service1 = Factory(:sc_service,:approval_status => 'A')
      sc_service2 = Factory(:sc_service, :approved_id => sc_service1.id)
      sc_service1.should_not be_valid
      sc_service1.errors_on(:base).should == ["Unapproved Record Already Exists for this record"]
    end
    
    it { should validate_length_of(:url).is_at_most(100) }
    it { should validate_length_of(:http_username).is_at_most(100) }
    it { should validate_length_of(:http_password).is_at_most(50) }
    
    it "should validate presence of http_username and http_password" do
      sc_service = Factory.build(:sc_service, http_username: 'divya', http_password: nil)
      sc_service.save.should == false
      sc_service.errors_on(:http_password).should == ["can't be blank"]
      
      sc_service = Factory.build(:sc_service, http_username: nil, http_password: 'pass@123')
      sc_service.save.should == false
      sc_service.errors_on(:http_password).should == ["must be blank"]
      
      sc_service = Factory.build(:sc_service, http_username: 'divya', http_password: 'pass@123')
      sc_service.save.should == true
    end
  end
  
  context "format" do      
    context "pool_customer_id, pool_account_no" do
      it "should accept value matching the format" do
        [:http_username].each do |att|
          should allow_value('APP123').for(att)
          should allow_value('APP_23456').for(att)
          should allow_value('APP.23456').for(att)
        end
      end

      it "should not accept value which does not match the format" do
        [:http_username].each do |att|
          should_not allow_value('APP@123!').for(att)
          should_not allow_value('app~@123*^').for(att)
        end
      end
      
      it "should accept value matching the format" do
        [:url].each do |att|
          should allow_value('http://example.com').for(att)
        end
      end

      it "should not accept value which does not match the format" do
        [:url].each do |att|
          should_not allow_value('APP@123!').for(att)
          should_not allow_value('app~@123*^').for(att)
          should_not allow_value('example.com').for(att)
        end
      end
    end
    
    context "validate_presence_of_http_password if http_username is present" do
      it "should validate presence of http_password if http_username is present" do
        sc_service = Factory.build(:sc_service, http_username: '123')
        sc_service.save.should == false
        sc_service.errors_on(:http_password).should == ["can't be blank"]
        
        sc_service = Factory.build(:sc_service, http_username: '123', http_password: 'pass@123')
        sc_service.save.should == true
      end
    end
  end
  
  context "encrypt_values" do 
    it "should encrypt the http_password" do 
      sc_service = Factory.build(:sc_service, http_username: 'http_username', http_password: 'http_password')
      sc_service.save.should be_true
      sc_service.reload
      sc_service.http_password.should == "http_password"
    end
  end
  
  context "decrypt_values" do 
    it "should decrypt the http_http_password" do 
      sc_service = Factory.build(:sc_service, http_username: 'http_username', http_password: 'http_password')
      sc_service.http_password.should == "http_password"
    end
  end

  context "default_scope" do 
    it "should only return 'A' records by default" do 
      sc_service1 = Factory(:sc_service, :approval_status => 'A') 
      sc_service2 = Factory(:sc_service, url: 'https://google.com')
      ScService.all.should == [sc_service1]
      sc_service2.approval_status = 'A'
      sc_service2.save
      ScService.all.should == [sc_service1,sc_service2]
    end
  end

  context "create_unapproved_record_entrys" do 
    it "should create unapproved_record_entry if the approval_status is 'U' and there is no previous record" do
      sc_service = Factory(:sc_service)
      sc_service.reload
      sc_service.unapproved_record_entry.should_not be_nil
      record = sc_service.unapproved_record_entry
      sc_service.save
      sc_service.unapproved_record_entry.should == record
    end

    it "should not create unapproved_record_entry if the approval_status is 'A'" do
      sc_service = Factory(:sc_service, :approval_status => 'A')
      sc_service.unapproved_record_entry.should be_nil
    end
  end

  context "unapproved_record_entrys" do 
    it "oncreate: should create unapproved_record_entry if the approval_status is 'U'" do
      sc_service = Factory(:sc_service)
      sc_service.reload
      sc_service.unapproved_record_entry.should_not be_nil
    end

    it "oncreate: should not create unapproved_record_entry if the approval_status is 'A'" do
      sc_service = Factory(:sc_service, :approval_status => 'A')
      sc_service.unapproved_record_entry.should be_nil
    end

    it "onupdate: should not remove unapproved_record_entry if approval_status did not change from U to A" do
      sc_service = Factory(:sc_service)
      sc_service.reload
      sc_service.unapproved_record_entry.should_not be_nil
      record = sc_service.unapproved_record_entry
      # we are editing the U record, before it is approved
      sc_service.url = 'http://example.com'
      sc_service.save
      sc_service.reload
      sc_service.unapproved_record_entry.should == record
    end
    
    it "onupdate: should remove unapproved_record_entry if the approval_status changed from 'U' to 'A' (approval)" do
      sc_service = Factory(:sc_service)
      sc_service.reload
      sc_service.unapproved_record_entry.should_not be_nil
      # the approval process changes the approval_status from U to A for a newly edited record
      sc_service.approval_status = 'A'
      sc_service.save
      sc_service.reload
      sc_service.unapproved_record_entry.should be_nil
    end
    
    it "ondestroy: should remove unapproved_record_entry if the record with approval_status 'U' was destroyed (approval) " do
      sc_service = Factory(:sc_service)
      sc_service.reload
      sc_service.unapproved_record_entry.should_not be_nil
      record = sc_service.unapproved_record_entry
      # the approval process destroys the U record, for an edited record 
      sc_service.destroy
      UnapprovedRecord.find_by_id(record.id).should be_nil
    end
  end

  context "approve" do 
    it "should approve unapproved_record" do 
      sc_service = Factory(:sc_service, :approval_status => 'U')
      sc_service.approve.save.should == true
      sc_service.approval_status.should == 'A'
    end

    it "should return error when trying to approve unmatched version" do 
      sc_service = Factory(:sc_service, :approval_status => 'A')
      sc_service2 = Factory(:sc_service, :approval_status => 'U', :approved_id => sc_service.id, :approved_version => 6)
      sc_service2.approve.should == "The record version is different from that of the approved version" 
    end
  end

  context "enable_approve_button?" do 
    it "should return true if approval_status is 'U' else false" do 
      sc_service1 = Factory(:sc_service, :approval_status => 'A')
      sc_service2 = Factory(:sc_service, :approval_status => 'U')
      sc_service1.enable_approve_button?.should == false
      sc_service2.enable_approve_button?.should == true
    end
  end
end
