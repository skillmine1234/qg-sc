require 'spec_helper'

describe ScService do
  context 'association' do
    it { should have_many(:incoming_file_types) }
  end

  context 'validation' do
    [:code, :name].each do |att|
      it { should validate_presence_of(att) }
    end

    it do
      sc_service = Factory(:sc_service)
      should validate_uniqueness_of(:name) 
      should validate_uniqueness_of(:code) 
    end
  end

  context "has_auto_upload?" do 
    it "should return true if atleast one incoming_file_type has auto_upload as 'Y" do 
      sc_service = Factory(:sc_service)
      incoming_file_record1 = Factory(:incoming_file_type, :sc_service_id => sc_service.id, :auto_upload => 'Y')
      incoming_file_record2 = Factory(:incoming_file_type, :sc_service_id => sc_service.id, :auto_upload => 'N')
      sc_service.has_auto_upload?.should == false
    end

    it "should return false if all the incoming_file_types have auto_upload as 'N" do 
      sc_service = Factory(:sc_service)
      incoming_file_record1 = Factory(:incoming_file_type, :sc_service_id => sc_service.id, :auto_upload => 'Y')
      incoming_file_record2 = Factory(:incoming_file_type, :sc_service_id => sc_service.id, :auto_upload => 'Y')
      sc_service.has_auto_upload?.should == true
    end
  end
end
