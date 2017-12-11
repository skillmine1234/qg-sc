require 'spec_helper'

describe ScServicesController do
  include HelperMethods
  
  before(:each) do
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
    sign_in @user = Factory(:user)
    Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'editor').id)
    request.env["HTTP_REFERER"] = "/"
  end

  describe "GET index" do
    it "assigns all sc_services as @sc_services" do
      sc_service = Factory(:sc_service, :approval_status => 'A')
      get :index
      assigns(:records).should eq([sc_service])
    end

    it "assigns all unapproved sc_services as @sc_services when approval_status is passed" do
      sc_service = Factory(:sc_service, :approval_status => 'U')
      get :index, :approval_status => 'U'
      assigns(:sc_services).should eq([sc_service])
    end
  end

  describe "GET show" do
    it "assigns the requested sc_service as @sc_service" do
      sc_service = Factory(:sc_service)
      get :show, {:id => sc_service.id}
      assigns(:sc_service).should eq(sc_service)
    end
  end

  describe "GET edit" do
    it "assigns the requested sc_service with status 'U' as @sc_service" do
      sc_service = Factory(:sc_service, :approval_status => 'U')
      get :edit, {:id => sc_service.id}
      assigns(:sc_service).should eq(sc_service)
    end

    it "assigns the requested sc_service with status 'A' as @sc_service" do
      sc_service = Factory(:sc_service, :approval_status => 'A')
      get :edit, {:id => sc_service.id}
      assigns(:sc_service).should eq(sc_service)
    end

    it "assigns the new sc_service with requested sc_service params when status 'A' as @sc_service" do
      sc_service = Factory(:sc_service, :approval_status => 'A')
      params = (sc_service.attributes).merge({:approved_id => sc_service.id, :approved_version => sc_service.lock_version})
      get :edit, {:id => sc_service.id}
      assigns(:sc_service).should eq(ScService.new(params))
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new sc_service" do
        params = Factory.attributes_for(:sc_service)
        expect {
          post :create, {:sc_service => params}
        }.to change(ScService.unscoped, :count).by(1)
        flash[:alert].should  match(/ScService successfully created and is pending for approval/)
        response.should be_redirect
      end

      it "assigns a newly created sc_service as @sc_service" do
        params = Factory.attributes_for(:sc_service)
        post :create, {:sc_service => params}
        assigns(:sc_service).should be_a(ScService)
        assigns(:sc_service).should be_persisted
      end

      it "redirects to the created sc_service" do
        params = Factory.attributes_for(:sc_service)
        post :create, {:sc_service => params}
        response.should redirect_to(ScService.unscoped.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved sc_service as @sc_service" do
        params = Factory.attributes_for(:sc_service)
        params[:code] = nil
        expect {
          post :create, {:sc_service => params}
        }.to change(ScService, :count).by(0)
        assigns(:sc_service).should be_a(ScService)
        assigns(:sc_service).should_not be_persisted
      end

      it "re-renders the 'new' template when show_errors is true" do
        params = Factory.attributes_for(:sc_service)
        params[:code] = nil
        post :create, {:sc_service => params}
        response.should render_template("edit")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested sc_service" do
        sc_service = Factory(:sc_service, :code => "7766")
        params = sc_service.attributes.slice(*sc_service.class.attribute_names)
        params[:code] = "7767"
        put :update, {:id => sc_service.id, :sc_service => params}
        sc_service.reload
        sc_service.code.should == "7767"
      end

      it "assigns the requested sc_service as @sc_service" do
        sc_service = Factory(:sc_service, :code => "7768")
        params = sc_service.attributes.slice(*sc_service.class.attribute_names)
        params[:code] = "7768"
        put :update, {:id => sc_service.to_param, :sc_service => params}
        assigns(:sc_service).should eq(sc_service)
      end

      it "redirects to the sc_service" do
        sc_service = Factory(:sc_service, :code => "7769")
        params = sc_service.attributes.slice(*sc_service.class.attribute_names)
        params[:code] = "7769"
        put :update, {:id => sc_service.to_param, :sc_service => params}
        response.should redirect_to(sc_service)
      end

      it "should raise error when tried to update at same time by many" do
        sc_service = Factory(:sc_service, :code => "7770")
        params = sc_service.attributes.slice(*sc_service.class.attribute_names)
        params[:code] = "7770"
        sc_service2 = sc_service
        put :update, {:id => sc_service.id, :sc_service => params}
        sc_service.reload
        sc_service.code.should == "7770"
        params[:code] = "7771"
        put :update, {:id => sc_service2.id, :sc_service => params}
        sc_service.reload
        sc_service.code.should == "7770"
        flash[:alert].should  match(/Someone edited the sc_service the same time you did. Please re-apply your changes to the sc_service./)
      end
    end

    describe "with invalid params" do
      it "assigns the sc_service as @sc_service" do
        sc_service = Factory(:sc_service, :code => "7771")
        params = sc_service.attributes.slice(*sc_service.class.attribute_names)
        params[:code] = nil
        put :update, {:id => sc_service.to_param, :sc_service => params}
        assigns(:sc_service).should eq(sc_service)
        sc_service.reload
        params[:code] = nil
      end

      it "re-renders the 'edit' template when show_errors is true" do
        sc_service = Factory(:sc_service)
        params = sc_service.attributes.slice(*sc_service.class.attribute_names)
        params[:code] = nil
        put :update, {:id => sc_service.id, :sc_service => params, :show_errors => "true"}
        response.should render_template("edit")
      end
    end
  end
 
  describe "GET audit_logs" do
    it "assigns the requested sc_service as @sc_service" do
      sc_service = Factory(:sc_service)
      get :audit_logs, {:id => sc_service.id, :version_id => 0}
      assigns(:record).should eq(sc_service)
      assigns(:audit).should eq(sc_service.audits.first)
      get :audit_logs, {:id => 12345, :version_id => "i"}
      assigns(:record).should eq(nil)
      assigns(:audit).should eq(nil)
    end
  end

  describe "PUT approve" do
    it "(edit) unapproved record can be approved and old approved record will be updated" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      sc_service1 = Factory(:sc_service, :approval_status => 'A')
      sc_service2 = Factory(:sc_service, :approval_status => 'U', :code => '7772', :approved_version => sc_service1.lock_version, :approved_id => sc_service1.id, :created_by => 666)
      # the following line is required for reload to get triggered (TODO)
      sc_service1.approval_status.should == 'A'
      UnapprovedRecord.count.should == 1
      put :approve, {:id => sc_service2.id}
      UnapprovedRecord.count.should == 0
      sc_service1.reload
      sc_service1.code.should == '7772'
      sc_service1.updated_by.should == "666"
      UnapprovedRecord.find_by_id(sc_service2.id).should be_nil
    end

    it "(create) unapproved record can be approved" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      sc_service = Factory(:sc_service, :code => '7772', :approval_status => 'U')
      UnapprovedRecord.count.should == 1
      put :approve, {:id => sc_service.id}
      UnapprovedRecord.count.should == 0
      sc_service.reload
      sc_service.code.should == '7772'
      sc_service.approval_status.should == 'A'
    end
  end
end
