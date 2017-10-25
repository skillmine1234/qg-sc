require 'spec_helper'

describe ScBackendSettingsController do  
  before(:each) do
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
    sign_in @user = Factory(:user)
    Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'editor').id)
    request.env["HTTP_REFERER"] = "/"
  end

  describe "GET index" do
    it "assigns all sc_backend_settings as @sc_backend_settings" do
      sc_backend_setting = Factory(:sc_backend_setting, :approval_status => 'A')
      get :index
      assigns(:records).should eq([sc_backend_setting])
    end

    it "assigns all unapproved sc_backend_settings as @sc_backend_settings when approval_status is passed" do
      sc_backend_setting = Factory(:sc_backend_setting, :approval_status => 'U')
      get :index, :approval_status => 'U'
      assigns(:records).should eq([sc_backend_setting])
    end
  end

  describe "GET show" do
    it "assigns the requested sc_backend_setting as @sc_backend_setting" do
      sc_backend_setting = Factory(:sc_backend_setting)
      get :show, {:id => sc_backend_setting.id}
      assigns(:sc_backend_setting).should eq(sc_backend_setting)
    end
  end

  describe "GET new" do
    it "assigns a new sc_backend_setting as @sc_backend_setting" do
      get :new
      assigns(:sc_backend_setting).should be_a_new(ScBackendSetting)
    end
  end

  describe "GET edit" do
    it "assigns the requested sc_backend_setting with status 'U' as @sc_backend_setting" do
      sc_backend_setting = Factory(:sc_backend_setting, :approval_status => 'U')
      get :edit, {:id => sc_backend_setting.id}
      assigns(:sc_backend_setting).should eq(sc_backend_setting)
    end

    it "assigns the requested sc_backend_setting with status 'A' as @sc_backend_setting" do
      sc_backend_setting = Factory(:sc_backend_setting, :approval_status => 'A')
      get :edit, {:id => sc_backend_setting.id}
      assigns(:sc_backend_setting).should eq(sc_backend_setting)
    end

    it "assigns the new sc_backend_setting with requested sc_backend_setting params when status 'A' as @sc_backend_setting" do
      sc_backend_setting = Factory(:sc_backend_setting, :approval_status => 'A')
      params = (sc_backend_setting.attributes).merge({:approved_id => sc_backend_setting.id, :approved_version => sc_backend_setting.lock_version})
      get :edit, {:id => sc_backend_setting.id}
      assigns(:sc_backend_setting).should eq(ScBackendSetting.new(params))
    end
  end
  
  describe "POST create" do
    describe "with valid params" do
      it "creates a new sc_backend_setting" do
        params = Factory.attributes_for(:sc_backend_setting)
        expect {
          post :create, {:sc_backend_setting => params}
        }.to change(ScBackendSetting.unscoped, :count).by(1)
        flash[:alert].should  match(/Setting successfully created is pending for approval/)
        response.should be_redirect
      end

      it "assigns a newly created sc_backend_setting as @sc_backend_setting" do
        params = Factory.attributes_for(:sc_backend_setting)
        post :create, {:sc_backend_setting => params}
        assigns(:sc_backend_setting).should be_a(ScBackendSetting)
        assigns(:sc_backend_setting).should be_persisted
      end

      it "redirects to the created sc_backend_setting" do
        params = Factory.attributes_for(:sc_backend_setting)
        post :create, {:sc_backend_setting => params}
        response.should redirect_to(ScBackendSetting.unscoped.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved sc_backend_setting as @sc_backend_setting" do
        params = Factory.attributes_for(:sc_backend_setting)
        params[:backend_code] = nil
        expect {
          post :create, {:sc_backend_setting => params}
        }.to change(ScBackendSetting, :count).by(0)
        assigns(:sc_backend_setting).should be_a(ScBackendSetting)
        assigns(:sc_backend_setting).should_not be_persisted
      end

      it "re-renders the 'new' template when show_errors is true" do
        params = Factory.attributes_for(:sc_backend_setting)
        params[:backend_code] = nil
        post :create, {:sc_backend_setting => params}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested sc_backend_setting" do
        sc_backend_setting = Factory(:sc_backend_setting, :backend_code => "Foo")
        params = sc_backend_setting.attributes.slice(*sc_backend_setting.class.attribute_names)
        params[:backend_code] = "Bar"
        put :update, {:id => sc_backend_setting.id, :sc_backend_setting => params}
        sc_backend_setting.reload
        sc_backend_setting.backend_code.should == "Bar"
      end

      it "assigns the requested sc_backend_setting as @sc_backend_setting" do
        sc_backend_setting = Factory(:sc_backend_setting, :backend_code => "Foo")
        params = sc_backend_setting.attributes.slice(*sc_backend_setting.class.attribute_names)
        params[:backend_code] = "Bar"
        put :update, {:id => sc_backend_setting.to_param, :sc_backend_setting => params}
        assigns(:sc_backend_setting).should eq(sc_backend_setting)
      end

      it "redirects to the sc_backend_setting" do
        sc_backend_setting = Factory(:sc_backend_setting, :backend_code => "Foo")
        params = sc_backend_setting.attributes.slice(*sc_backend_setting.class.attribute_names)
        params[:backend_code] = "Bar"
        put :update, {:id => sc_backend_setting.to_param, :sc_backend_setting => params}
        response.should redirect_to(sc_backend_setting)
      end

      it "should raise error when tried to update at same time by many" do
        sc_backend_setting = Factory(:sc_backend_setting, :backend_code => "Foo")
        params = sc_backend_setting.attributes.slice(*sc_backend_setting.class.attribute_names)
        params[:backend_code] = "Bar"
        sc_backend_setting2 = sc_backend_setting
        put :update, {:id => sc_backend_setting.id, :sc_backend_setting => params}
        sc_backend_setting.reload
        sc_backend_setting.backend_code.should == "Bar"
        params[:backend_code] = "Jim"
        put :update, {:id => sc_backend_setting2.id, :sc_backend_setting => params}
        sc_backend_setting.reload
        sc_backend_setting.backend_code.should == "Bar"
        flash[:alert].should  match(/Someone edited the record the same time you did. Please re-apply your changes to the record./)
      end
    end

    describe "with invalid params" do
      it "assigns the sc_backend_setting as @sc_backend_setting" do
        sc_backend_setting = Factory(:sc_backend_setting, :backend_code => "Foo")
        params = sc_backend_setting.attributes.slice(*sc_backend_setting.class.attribute_names)
        params[:backend_code] = nil
        put :update, {:id => sc_backend_setting.to_param, :sc_backend_setting => params}
        assigns(:sc_backend_setting).should eq(sc_backend_setting)
        sc_backend_setting.reload
        params[:backend_code] = nil
      end

      it "re-renders the 'edit' template when show_errors is true" do
        sc_backend_setting = Factory(:sc_backend_setting)
        params = sc_backend_setting.attributes.slice(*sc_backend_setting.class.attribute_names)
        params[:backend_code] = nil
        put :update, {:id => sc_backend_setting.id, :sc_backend_setting => params, :show_errors => "true"}
        response.should render_template("edit")
      end
    end
  end
 
  describe "GET audit_logs" do
    it "assigns the requested sc_backend_setting as @sc_backend_setting" do
      sc_backend_setting = Factory(:sc_backend_setting)
      get :audit_logs, {:id => sc_backend_setting.id, :version_id => 0}
      assigns(:record).should eq(sc_backend_setting)
      assigns(:audit).should eq(sc_backend_setting.audits.first)
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
      sc_backend_setting1 = Factory(:sc_backend_setting, :approval_status => 'A')
      sc_backend_setting2 = Factory(:sc_backend_setting, :approval_status => 'U', :backend_code => 'Foo', :approved_version => sc_backend_setting1.lock_version, :approved_id => sc_backend_setting1.id, :created_by => 666)
      # the following line is required for reload to get triggered (TODO)
      sc_backend_setting1.approval_status.should == 'A'
      UnapprovedRecord.count.should == 1
      put :approve, {:id => sc_backend_setting2.id}
      UnapprovedRecord.count.should == 0
      sc_backend_setting1.reload
      sc_backend_setting1.backend_code.should == 'Foo'
      sc_backend_setting1.updated_by.should == "666"
      UnapprovedRecord.find_by_id(sc_backend_setting2.id).should be_nil
    end

    it "(create) unapproved record can be approved" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      sc_backend_setting = Factory(:sc_backend_setting, :backend_code => 'Foo', :approval_status => 'U')
      UnapprovedRecord.count.should == 1
      put :approve, {:id => sc_backend_setting.id}
      UnapprovedRecord.count.should == 0
      sc_backend_setting.reload
      sc_backend_setting.backend_code.should == 'Foo'
      sc_backend_setting.approval_status.should == 'A'
    end
  end
end
