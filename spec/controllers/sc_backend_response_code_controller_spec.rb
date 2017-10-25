require 'spec_helper'

describe ScBackendResponseCodesController do  
  before(:each) do
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
    sign_in @user = Factory(:user)
    Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'editor').id)
    request.env["HTTP_REFERER"] = "/"
  end

  describe "GET index" do
    it "assigns all sc_backend_response_codes as @sc_backend_response_codes" do
      sc_backend_response_code = Factory(:sc_backend_response_code, :approval_status => 'A')
      get :index
      assigns(:records).should eq([sc_backend_response_code])
    end

    it "assigns all unapproved sc_backend_response_codes as @sc_backend_response_codes when approval_status is passed" do
      sc_backend_response_code = Factory(:sc_backend_response_code, :approval_status => 'U')
      get :index, :approval_status => 'U'
      assigns(:records).should eq([sc_backend_response_code])
    end
  end

  describe "GET show" do
    it "assigns the requested sc_backend_response_code as @sc_backend_response_code" do
      sc_backend_response_code = Factory(:sc_backend_response_code)
      get :show, {:id => sc_backend_response_code.id}
      assigns(:sc_backend_response_code).should eq(sc_backend_response_code)
    end
  end

  describe "GET new" do
    it "assigns a new sc_backend_response_code as @sc_backend_response_code" do
      get :new
      assigns(:sc_backend_response_code).should be_a_new(ScBackendResponseCode)
    end
  end

  describe "GET edit" do
    it "assigns the requested sc_backend_response_code with status 'U' as @sc_backend_response_code" do
      sc_backend_response_code = Factory(:sc_backend_response_code, :approval_status => 'U')
      get :edit, {:id => sc_backend_response_code.id}
      assigns(:sc_backend_response_code).should eq(sc_backend_response_code)
    end

    it "assigns the requested sc_backend_response_code with status 'A' as @sc_backend_response_code" do
      sc_backend_response_code = Factory(:sc_backend_response_code, :approval_status => 'A')
      get :edit, {:id => sc_backend_response_code.id}
      assigns(:sc_backend_response_code).should eq(sc_backend_response_code)
    end

    it "assigns the new sc_backend_response_code with requested sc_backend_response_code params when status 'A' as @sc_backend_response_code" do
      sc_backend_response_code = Factory(:sc_backend_response_code, :approval_status => 'A')
      params = (sc_backend_response_code.attributes).merge({:approved_id => sc_backend_response_code.id, :approved_version => sc_backend_response_code.lock_version})
      get :edit, {:id => sc_backend_response_code.id}
      assigns(:sc_backend_response_code).should eq(ScBackendResponseCode.new(params))
    end
  end
  
  describe "POST create" do
    describe "with valid params" do
      it "creates a new sc_backend_response_code" do
        params = Factory.attributes_for(:sc_backend_response_code)
        expect {
          post :create, {:sc_backend_response_code => params}
        }.to change(ScBackendResponseCode.unscoped, :count).by(1)
        flash[:alert].should  match(/Code successfully created is pending for approval/)
        response.should be_redirect
      end

      it "assigns a newly created sc_backend_response_code as @sc_backend_response_code" do
        params = Factory.attributes_for(:sc_backend_response_code)
        post :create, {:sc_backend_response_code => params}
        assigns(:sc_backend_response_code).should be_a(ScBackendResponseCode)
        assigns(:sc_backend_response_code).should be_persisted
      end

      it "redirects to the created sc_backend_response_code" do
        params = Factory.attributes_for(:sc_backend_response_code)
        post :create, {:sc_backend_response_code => params}
        response.should redirect_to(ScBackendResponseCode.unscoped.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved sc_backend_response_code as @sc_backend_response_code" do
        params = Factory.attributes_for(:sc_backend_response_code)
        params[:response_code] = nil
        expect {
          post :create, {:sc_backend_response_code => params}
        }.to change(ScBackendResponseCode, :count).by(0)
        assigns(:sc_backend_response_code).should be_a(ScBackendResponseCode)
        assigns(:sc_backend_response_code).should_not be_persisted
      end

      it "re-renders the 'new' template when show_errors is true" do
        params = Factory.attributes_for(:sc_backend_response_code)
        params[:response_code] = nil
        post :create, {:sc_backend_response_code => params}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested sc_backend_response_code" do
        sc_backend_response_code = Factory(:sc_backend_response_code, :response_code => "Foo")
        params = sc_backend_response_code.attributes.slice(*sc_backend_response_code.class.attribute_names)
        params[:response_code] = "Bar"
        put :update, {:id => sc_backend_response_code.id, :sc_backend_response_code => params}
        sc_backend_response_code.reload
        sc_backend_response_code.response_code.should == "Bar"
      end

      it "assigns the requested sc_backend_response_code as @sc_backend_response_code" do
        sc_backend_response_code = Factory(:sc_backend_response_code, :response_code => "Foo")
        params = sc_backend_response_code.attributes.slice(*sc_backend_response_code.class.attribute_names)
        params[:response_code] = "Bar"
        put :update, {:id => sc_backend_response_code.to_param, :sc_backend_response_code => params}
        assigns(:sc_backend_response_code).should eq(sc_backend_response_code)
      end

      it "redirects to the sc_backend_response_code" do
        sc_backend_response_code = Factory(:sc_backend_response_code, :response_code => "Foo")
        params = sc_backend_response_code.attributes.slice(*sc_backend_response_code.class.attribute_names)
        params[:response_code] = "Bar"
        put :update, {:id => sc_backend_response_code.to_param, :sc_backend_response_code => params}
        response.should redirect_to(sc_backend_response_code)
      end

      it "should raise error when tried to update at same time by many" do
        sc_backend_response_code = Factory(:sc_backend_response_code, :response_code => "Foo")
        params = sc_backend_response_code.attributes.slice(*sc_backend_response_code.class.attribute_names)
        params[:response_code] = "Bar"
        sc_backend_response_code2 = sc_backend_response_code
        put :update, {:id => sc_backend_response_code.id, :sc_backend_response_code => params}
        sc_backend_response_code.reload
        sc_backend_response_code.response_code.should == "Bar"
        params[:response_code] = "Jim"
        put :update, {:id => sc_backend_response_code2.id, :sc_backend_response_code => params}
        sc_backend_response_code.reload
        sc_backend_response_code.response_code.should == "Bar"
        flash[:alert].should  match(/Someone edited the code the same time you did. Please re-apply your changes to the code./)
      end
    end

    describe "with invalid params" do
      it "assigns the sc_backend_response_code as @sc_backend_response_code" do
        sc_backend_response_code = Factory(:sc_backend_response_code, :response_code => "Foo")
        params = sc_backend_response_code.attributes.slice(*sc_backend_response_code.class.attribute_names)
        params[:response_code] = nil
        put :update, {:id => sc_backend_response_code.to_param, :sc_backend_response_code => params}
        assigns(:sc_backend_response_code).should eq(sc_backend_response_code)
        sc_backend_response_code.reload
        params[:response_code] = nil
      end

      it "re-renders the 'edit' template when show_errors is true" do
        sc_backend_response_code = Factory(:sc_backend_response_code)
        params = sc_backend_response_code.attributes.slice(*sc_backend_response_code.class.attribute_names)
        params[:response_code] = nil
        put :update, {:id => sc_backend_response_code.id, :sc_backend_response_code => params, :show_errors => "true"}
        response.should render_template("edit")
      end
    end
  end
 
  describe "GET audit_logs" do
    it "assigns the requested sc_backend_response_code as @sc_backend_response_code" do
      sc_backend_response_code = Factory(:sc_backend_response_code)
      get :audit_logs, {:id => sc_backend_response_code.id, :version_id => 0}
      assigns(:sc_backend_response_code).should eq(sc_backend_response_code)
      assigns(:audit).should eq(sc_backend_response_code.audits.first)
      get :audit_logs, {:id => 12345, :version_id => "i"}
      assigns(:sc_backend_response_code).should eq(nil)
      assigns(:audit).should eq(nil)
    end
  end

  describe "PUT approve" do
    it "(edit) unapproved record can be approved and old approved record will be updated" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      sc_backend_response_code1 = Factory(:sc_backend_response_code, :approval_status => 'A')
      sc_backend_response_code2 = Factory(:sc_backend_response_code, :approval_status => 'U', :response_code => 'Foo', :approved_version => sc_backend_response_code1.lock_version, :approved_id => sc_backend_response_code1.id, :created_by => 666)
      # the following line is required for reload to get triggered (TODO)
      sc_backend_response_code1.approval_status.should == 'A'
      UnapprovedRecord.count.should == 1
      put :approve, {:id => sc_backend_response_code2.id}
      UnapprovedRecord.count.should == 0
      sc_backend_response_code1.reload
      sc_backend_response_code1.response_code.should == 'Foo'
      sc_backend_response_code1.updated_by.should == "666"
      UnapprovedRecord.find_by_id(sc_backend_response_code2.id).should be_nil
    end

    it "(create) unapproved record can be approved" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      sc_backend_response_code = Factory(:sc_backend_response_code, :response_code => 'Foo', :approval_status => 'U')
      UnapprovedRecord.count.should == 1
      put :approve, {:id => sc_backend_response_code.id}
      UnapprovedRecord.count.should == 0
      sc_backend_response_code.reload
      sc_backend_response_code.response_code.should == 'Foo'
      sc_backend_response_code.approval_status.should == 'A'
    end
  end
end
