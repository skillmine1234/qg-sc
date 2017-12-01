require 'spec_helper'

describe ScProxy do
  context 'association' do
    it { should belong_to(:created_user) }
    it { should belong_to(:updated_user) }
    it { should have_one(:unapproved_record_entry) }
    it { should belong_to(:approved_record) }
  end
  
  context 'validation' do
    [:url, :is_enabled].each do |att|
      it { should validate_presence_of(att) }
    end
    
    it { should validate_uniqueness_of(:url).scoped_to(:approval_status) }
    
    it "should validate_unapproved_record" do 
      sc_proxy1 = Factory(:sc_proxy,:approval_status => 'A')
      sc_proxy2 = Factory(:sc_proxy, :approved_id => sc_proxy1.id)
      sc_proxy1.should_not be_valid
      sc_proxy1.errors_on(:base).should == ["Unapproved Record Already Exists for this record"]
    end
    
    it { should validate_length_of(:url).is_at_most(100) }
    it { should validate_length_of(:username).is_at_most(100) }
    it { should validate_length_of(:password).is_at_most(50) }
  end
  
  context "format" do      
    context "pool_customer_id, pool_account_no" do
      it "should accept value matching the format" do
        [:username].each do |att|
          should allow_value('APP123').for(att)
          should allow_value('APP_23456').for(att)
          should allow_value('APP.23456').for(att)
        end
      end

      it "should not accept value which does not match the format" do
        [:username].each do |att|
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
    
    context "validate_presence_of_password if username is present" do
      it "should validate presence of password if username is present" do
        sc_proxy = Factory.build(:sc_proxy, username: '123')
        sc_proxy.save.should == false
        sc_proxy.errors_on(:password).should == ["can't be blank"]
        
        sc_proxy = Factory.build(:sc_proxy, username: '123', password: 'pass@123')
        sc_proxy.save.should == true
      end
    end
  end
  
  context "encrypt_values" do 
    it "should encrypt the password" do 
      sc_proxy = Factory.build(:sc_proxy, username: 'username', password: 'password')
      sc_proxy.save.should be_true
      sc_proxy.reload
      sc_proxy.password.should == "password"
    end
  end
  
  context "decrypt_values" do 
    it "should decrypt the http_password" do 
      sc_proxy = Factory.build(:sc_proxy, username: 'username', password: 'password')
      sc_proxy.password.should == "password"
    end
  end

  context "default_scope" do 
    it "should only return 'A' records by default" do 
      sc_proxy1 = Factory(:sc_proxy, :approval_status => 'A') 
      sc_proxy2 = Factory(:sc_proxy, url: 'https://google.com')
      ScProxy.all.should == [sc_proxy1]
      sc_proxy2.approval_status = 'A'
      sc_proxy2.save
      ScProxy.all.should == [sc_proxy1,sc_proxy2]
    end
  end

  context "create_unapproved_record_entrys" do 
    it "should create unapproved_record_entry if the approval_status is 'U' and there is no previous record" do
      sc_proxy = Factory(:sc_proxy)
      sc_proxy.reload
      sc_proxy.unapproved_record_entry.should_not be_nil
      record = sc_proxy.unapproved_record_entry
      sc_proxy.save
      sc_proxy.unapproved_record_entry.should == record
    end

    it "should not create unapproved_record_entry if the approval_status is 'A'" do
      sc_proxy = Factory(:sc_proxy, :approval_status => 'A')
      sc_proxy.unapproved_record_entry.should be_nil
    end
  end

  context "unapproved_record_entrys" do 
    it "oncreate: should create unapproved_record_entry if the approval_status is 'U'" do
      sc_proxy = Factory(:sc_proxy)
      sc_proxy.reload
      sc_proxy.unapproved_record_entry.should_not be_nil
    end

    it "oncreate: should not create unapproved_record_entry if the approval_status is 'A'" do
      sc_proxy = Factory(:sc_proxy, :approval_status => 'A')
      sc_proxy.unapproved_record_entry.should be_nil
    end

    it "onupdate: should not remove unapproved_record_entry if approval_status did not change from U to A" do
      sc_proxy = Factory(:sc_proxy)
      sc_proxy.reload
      sc_proxy.unapproved_record_entry.should_not be_nil
      record = sc_proxy.unapproved_record_entry
      # we are editing the U record, before it is approved
      sc_proxy.url = 'http://example.com'
      sc_proxy.save
      sc_proxy.reload
      sc_proxy.unapproved_record_entry.should == record
    end
    
    it "onupdate: should remove unapproved_record_entry if the approval_status changed from 'U' to 'A' (approval)" do
      sc_proxy = Factory(:sc_proxy)
      sc_proxy.reload
      sc_proxy.unapproved_record_entry.should_not be_nil
      # the approval process changes the approval_status from U to A for a newly edited record
      sc_proxy.approval_status = 'A'
      sc_proxy.save
      sc_proxy.reload
      sc_proxy.unapproved_record_entry.should be_nil
    end
    
    it "ondestroy: should remove unapproved_record_entry if the record with approval_status 'U' was destroyed (approval) " do
      sc_proxy = Factory(:sc_proxy)
      sc_proxy.reload
      sc_proxy.unapproved_record_entry.should_not be_nil
      record = sc_proxy.unapproved_record_entry
      # the approval process destroys the U record, for an edited record 
      sc_proxy.destroy
      UnapprovedRecord.find_by_id(record.id).should be_nil
    end
  end

  context "approve" do 
    it "should approve unapproved_record" do 
      sc_proxy = Factory(:sc_proxy, :approval_status => 'U')
      sc_proxy.approve.save.should == true
      sc_proxy.approval_status.should == 'A'
    end

    it "should return error when trying to approve unmatched version" do 
      sc_proxy = Factory(:sc_proxy, :approval_status => 'A')
      sc_proxy2 = Factory(:sc_proxy, :approval_status => 'U', :approved_id => sc_proxy.id, :approved_version => 6)
      sc_proxy2.approve.should == "The record version is different from that of the approved version" 
    end
  end

  context "enable_approve_button?" do 
    it "should return true if approval_status is 'U' else false" do 
      sc_proxy1 = Factory(:sc_proxy, :approval_status => 'A')
      sc_proxy2 = Factory(:sc_proxy, :approval_status => 'U')
      sc_proxy1.enable_approve_button?.should == false
      sc_proxy2.enable_approve_button?.should == true
    end
  end
end
