require 'spec_helper'

describe ScFaultCodesController do
  include HelperMethods
  
  before(:each) do
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
    sign_in @user = Factory(:user)
    Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'editor').id)
    request.env["HTTP_REFERER"] = "/"
  end

  describe "GET index" do
    it "should assign all sc_fault_codes as @sc_fault_codes" do
      sc_fault_code = Factory(:sc_fault_code)
      get :index
      assigns(:records).should eq([sc_fault_code])
    end
  end

  describe "GET show" do
    it "should assign the requested sc_fault_code as @sc_fault_code" do
      sc_fault_code = Factory(:sc_fault_code)
      get :show, {:id => sc_fault_code.id}
      assigns(:sc_fault_code).should eq(sc_fault_code)
    end
  end

  context "GET get fault reason" do
    it "gets the fault reason" do
      sc_fault_code = Factory(:sc_fault_code)
      get :get_fault_reason, :fault_code => sc_fault_code.fault_code, :format => :json
      response.should be_ok
      body = JSON.parse(response.body)
      body.should == {"reason" => sc_fault_code.fault_reason}
    end
  end
end
