require 'spec_helper'

describe ScBackend do
  context 'association' do
    it { should belong_to(:created_user) }
    it { should belong_to(:updated_user) }
    it { should belong_to(:unapproved_record) }
    it { should belong_to(:approved_record) }
    it { should have_one(:sc_backend_stat) }
    it { should have_one(:sc_backend_status) }
    it { should have_many(:sc_backend_status_changes) }
  end

  context 'validation' do
    [:code, :do_auto_shutdown, :max_consecutive_failures, :window_in_mins, :max_window_failures, 
     :do_auto_start, :min_consecutive_success, :min_window_success, :use_proxy].each do |att|
      it { should validate_presence_of(att) }
    end

    it "should return error if integer fields are less than 0" do
      sc_backend = Factory.build(:sc_backend, :max_consecutive_failures => -9, :max_window_failures => -7, :min_consecutive_success => -8, :min_window_success => -6)
      sc_backend.should_not be_valid
      sc_backend.errors_on(:max_consecutive_failures).should == ["must be greater than or equal to 0"]
      sc_backend.errors_on(:max_window_failures).should == ["must be greater than or equal to 0"]
      sc_backend.errors_on(:min_consecutive_success).should == ["must be greater than or equal to 0"]
      sc_backend.errors_on(:min_window_success).should == ["must be greater than or equal to 0"]
    end

    it "should return error if integer fields are not integer" do
      sc_backend = Factory.build(:sc_backend, :max_consecutive_failures => 6.5, :max_window_failures => 8.5, :min_consecutive_success => 7.5, :min_window_success => 9.5)
      sc_backend.errors_on(:max_consecutive_failures).should == ["must be an integer"]
      sc_backend.errors_on(:max_window_failures).should == ["must be an integer"]
      sc_backend.errors_on(:min_consecutive_success).should == ["must be an integer"]
      sc_backend.errors_on(:min_window_success).should == ["must be an integer"]
    end
    
    [:url].each do |att|
      it { should validate_length_of(att).is_at_most(100) }
    end

    it do
      sc_backend = Factory(:sc_backend, :approval_status => 'A')

      should validate_length_of(:code).is_at_most(20)
      should validate_length_of(:do_auto_shutdown).is_at_least(1).is_at_most(1)
      should validate_length_of(:do_auto_start).is_at_least(1).is_at_most(1)
    end

    it do
      should validate_inclusion_of(:window_in_mins).in_array([1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60])
    end

    it do 
      sc_backend = Factory(:sc_backend, :approval_status => 'A')
      should validate_uniqueness_of(:code).scoped_to(:approval_status)
    end
    
    it { should validate_numericality_of(:first_requery_after).is_greater_than(0) }
    it { should validate_numericality_of(:requery_interval).is_greater_than(0) }

    it "should return error if code is already taken" do
      sc_backend1 = Factory(:sc_backend, :code => "9933", :approval_status => 'A')
      sc_backend2 = Factory.build(:sc_backend, :code => "9933", :approval_status => 'A')
      sc_backend2.should_not be_valid
      sc_backend2.errors_on(:code).should == ["has already been taken"]
    end

    it "should return error when window_in_mins < 1" do
      sc_backend1 = Factory.build(:sc_backend, :window_in_mins => 0)
      sc_backend1.should_not be_valid
      sc_backend1.errors_on(:window_in_mins).should == ["Allowed Values: 1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60"]

      sc_backend2 = Factory.build(:sc_backend, :window_in_mins => -1)
      sc_backend2.should_not be_valid
      sc_backend2.errors_on(:window_in_mins).should == ["Allowed Values: 1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60"]
    end

    it "should return error when window_in_mins > 60" do
      sc_backend1 = Factory.build(:sc_backend, :window_in_mins => 61)
      sc_backend1.should_not be_valid
      sc_backend1.errors_on(:window_in_mins).should == ["Allowed Values: 1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60"]
    end

    it "should return error when window_in_mins is not divisor of 60" do
      sc_backend1 = Factory.build(:sc_backend, :window_in_mins => 7)
      sc_backend1.should_not be_valid
      sc_backend1.errors_on(:window_in_mins).should == ["Allowed Values: 1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30, 60"]
    end
    
    it { should validate_length_of(:http_username).is_at_most(100) }
    it { should validate_length_of(:http_password).is_at_most(50) }
    
    it "should validate presence of http_username and http_password" do
      sc_backend = Factory.build(:sc_backend, http_username: 'divya', http_password: nil)
      sc_backend.save.should == false
      sc_backend.errors_on(:http_password).should == ["can't be blank"]
      
      sc_backend = Factory.build(:sc_backend, http_username: nil, http_password: 'pass@123')
      sc_backend.save.should == false
      sc_backend.errors_on(:http_password).should == ["must be blank"]
      
      sc_backend = Factory.build(:sc_backend, http_username: 'divya', http_password: 'pass@123')
      sc_backend.save.should == true
    end
  end

  context "default_scope" do 
    it "should only return 'A' records by default" do 
      sc_backend1 = Factory(:sc_backend, :approval_status => 'A') 
      sc_backend2 = Factory(:sc_backend, :code => '9999')
      sc_backends = ScBackend.all
      ScBackend.all.should == [sc_backend1]
      sc_backend2.approval_status = 'A'
      sc_backend2.save
      ScBackend.all.should == [sc_backend1,sc_backend2]
    end
  end

  context "check_max_consecutive_failures" do 
    it "should validate max_consecutive_failures" do
      sc_backend1 = Factory.build(:sc_backend, :max_consecutive_failures => 10, :min_consecutive_success => 9, :max_window_failures => 11, :min_window_success => 12)
      sc_backend1.should_not be_valid
      sc_backend1.errors_on(:max_consecutive_failures).should == ["should be less than Minimum Consecutive Success"]
      sc_backend2 = Factory.build(:sc_backend, :max_consecutive_failures => 10, :min_consecutive_success => 11, :max_window_failures => 9, :min_window_success => 12)
      sc_backend2.should_not be_valid
      sc_backend2.errors_on(:max_consecutive_failures).should == ["should be less than Maximum Window Failures"]
      sc_backend3 = Factory.build(:sc_backend, :max_consecutive_failures => 10, :min_consecutive_success => 11, :max_window_failures => 12, :min_window_success => 9)
      sc_backend3.should_not be_valid
      sc_backend3.errors_on(:max_consecutive_failures).should == ["should be less than Minimum Window Success"]
    end
  end

  context "check_min_consecutive_success" do 
    it "should validate check_min_consecutive_success" do
      sc_backend1 = Factory.build(:sc_backend, :max_consecutive_failures => 4, :min_consecutive_success => 9, :max_window_failures => 8, :min_window_success => 10)
      sc_backend1.should_not be_valid
      sc_backend1.errors_on(:min_consecutive_success).should == ["should be less than Maximum Window Failures"]
      sc_backend2 = Factory.build(:sc_backend, :max_consecutive_failures => 4, :min_consecutive_success => 9, :max_window_failures => 10, :min_window_success => 8)
      sc_backend2.should_not be_valid
      sc_backend2.errors_on(:min_consecutive_success).should == ["should be less than Minimum Window Success"]
    end
  end

  context "check_max_window_failures" do 
    it "should validate check_min_consecutive_success" do
      sc_backend1 = Factory.build(:sc_backend, :max_consecutive_failures => 4, :min_consecutive_success => 8, :max_window_failures => 11, :min_window_success => 10)
      sc_backend1.should_not be_valid
      sc_backend1.errors_on(:max_window_failures).should == ["should be less than Minimum Window Success"]
    end
  end

  context "check_email_addresses" do 
    it "should validate email address" do 
      sc_backend = Factory.build(:sc_backend, :alert_email_to => "1234;esesdgs")
      sc_backend.should_not be_valid
      sc_backend.errors_on("alert_email_to").should == ["is invalid, expected format is abc@def.com"]
      
      sc_backend = Factory.build(:sc_backend, :alert_email_to => "foo@ruby.com;abe@def.com")
      sc_backend.should be_valid
    end
  end
  
  context "url format" do
    [:url].each do |att|
      it "should allow valid format" do
        should allow_value('http://localhost:3000/pc_products').for(att)
        should allow_value('localhost:3000').for(att)
      end
    
      it "should not allow invalid format" do
        should_not allow_value('localhost').for(att)
        should_not allow_value('@#@localhost').for(att)
      end
    end
  end
  
  
  context "encrypt_values" do 
    it "should encrypt the http_password" do 
      sc_backend = Factory.build(:sc_backend, http_username: 'http_username', http_password: 'http_password')
      sc_backend.save.should be_true
      sc_backend.reload
      sc_backend.http_password.should == "http_password"
    end
  end
  
  context "decrypt_values" do 
    it "should decrypt the http_http_password" do 
      sc_backend = Factory.build(:sc_backend, http_username: 'http_username', http_password: 'http_password')
      sc_backend.http_password.should == "http_password"
    end
  end
end
