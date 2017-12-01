require 'spec_helper'

describe ScProxiesController do
  include HelperMethods
  
  before(:each) do
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
    sign_in @user = Factory(:user)
    Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'editor').id)
    request.env["HTTP_REFERER"] = "/"
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new sc_proxy" do
        params = Factory.attributes_for(:sc_proxy)
        expect {
          post :create, {:sc_proxy => params}
        }.to change(ScProxy.unscoped, :count).by(1)
        flash[:alert].should  match(/ScProxy successfully created and is pending for approval/)
        response.should be_redirect
      end

      it "assigns a newly created sc_proxy as @sc_proxy" do
        params = Factory.attributes_for(:sc_proxy)
        post :create, {:sc_proxy => params}
        assigns(:sc_proxy).should be_a(ScProxy)
        assigns(:sc_proxy).should be_persisted
      end

      it "redirects to the created sc_proxy" do
        params = Factory.attributes_for(:sc_proxy)
        post :create, {:sc_proxy => params}
        response.should redirect_to(ScProxy.unscoped.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved sc_proxy as @sc_proxy" do
        params = Factory.attributes_for(:sc_proxy)
        params[:url] = nil
        expect {
          post :create, {:sc_proxy => params}
        }.to change(ScProxy, :count).by(0)
        assigns(:sc_proxy).should be_a(ScProxy)
        assigns(:sc_proxy).should_not be_persisted
      end

      it "re-renders the 'new' template when show_errors is true" do
        params = Factory.attributes_for(:sc_proxy)
        params[:url] = nil
        post :create, {:sc_proxy => params}
        response.should render_template("edit")
      end
    end
  end

  describe "GET index" do
    it "assigns all sc_proxies with approval_status 'U' as @sc_proxies" do
      sc_proxy1 = Factory(:sc_proxy, :approval_status => 'A')
      sc_proxy2 = Factory(:sc_proxy, :approval_status => 'U')
      get :index
      assigns(:sc_proxies).should eq([sc_proxy2])
    end
  end

  describe "GET show" do
    it "assigns the requested rule as @sc_proxy" do
      sc_proxy = Factory(:sc_proxy)
      get :show, {:id => sc_proxy.id}
      assigns(:sc_proxy).should eq(sc_proxy)
    end
  end
  
  describe "GET edit" do
    it "assigns the requested rule as @sc_proxy" do
      sc_proxy = Factory(:sc_proxy)
      get :edit, {:id => sc_proxy.id}
      assigns(:sc_proxy).should eq(sc_proxy)
    end

    it "assigns the requested sc_proxy with status 'A' as @sc_proxy" do
      sc_proxy = Factory(:sc_proxy,:approval_status => 'A')
      get :edit, {:id => sc_proxy.id}
      assigns(:sc_proxy).should eq(sc_proxy)
    end

    it "assigns the new sc_proxy with requested sc_proxy params when status 'A' as @sc_proxy" do
      sc_proxy = Factory(:sc_proxy,:approval_status => 'A')
      params = (sc_proxy.attributes).merge({:approved_id => sc_proxy.id,:approved_version => sc_proxy.lock_version})
      get :edit, {:id => sc_proxy.id}
      assigns(:sc_proxy).should eq(ScProxy.new(params))
    end
  end
  
  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested rule" do
        sc_proxy = Factory(:sc_proxy, :url => "http://example.com")
        params = sc_proxy.attributes.slice(*sc_proxy.class.attribute_names)
        params[:url] = "http://somewhere.com"
        put :update, {:id => sc_proxy.id, :sc_proxy => params}
        sc_proxy.reload
        sc_proxy.url.should == "http://somewhere.com"
      end

      it "assigns the requested rule as @sc_proxy" do
        sc_proxy = Factory(:sc_proxy, :url => "http://example.com")
        params = sc_proxy.attributes.slice(*sc_proxy.class.attribute_names)
        params[:url] = "http://somewhere.com"
        put :update, {:id => sc_proxy.to_param, :sc_proxy => params}
        assigns(:sc_proxy).should eq(sc_proxy)
      end

      it "redirects to the rule" do
        sc_proxy = Factory(:sc_proxy, :url => "http://example.com")
        params = sc_proxy.attributes.slice(*sc_proxy.class.attribute_names)
        params[:url] = "http://somewhere.com"
        put :update, {:id => sc_proxy.to_param, :sc_proxy => params}
        response.should redirect_to(sc_proxy)
      end

      it "should raise error when tried to update at same time by many" do
        sc_proxy = Factory(:sc_proxy, :url => "http://example.com")
        
        # update once
        params = sc_proxy.attributes.slice(*sc_proxy.class.attribute_names)
        params[:url] = "http://somewhere.com"
        put :update, {:id => sc_proxy.id, :sc_proxy => params}

        # update another time, without a reload, this will fail as the lock_version has changed 
        params = sc_proxy.attributes.slice(*sc_proxy.class.attribute_names)
        params[:url] = "http://qwerty.com"
        put :update, {:id => sc_proxy.id, :sc_proxy => params}
        flash[:alert].should  match(/Someone edited the rule the same time you did. Please re-apply your changes to the rule/)
      end
    end
  end

  describe "GET audit_logs" do
    it "assigns the requested rule as @sc_proxy" do
      sc_proxy = Factory(:sc_proxy)
      get :audit_logs, {:id => sc_proxy.id, :version_id => 0}
      assigns(:record).should eq(sc_proxy)
      assigns(:audit).should eq(sc_proxy.audits.first)
      get :audit_logs, {:id => 12345, :version_id => "e"}
      assigns(:record).should eq(nil)
      assigns(:audit).should eq(nil)
    end
  end

  describe "PUT approve" do
    it "(edit) unapproved record can be approved and old approved record will be updated" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      sc_proxy1 = Factory(:sc_proxy, :approval_status => 'A')
      sc_proxy2 = Factory(:sc_proxy, :url => "http://example.com", :approval_status => 'U', :approved_version => sc_proxy1.lock_version, :approved_id => sc_proxy1.id, :created_by => 666)
      # the following line is required for reload to get triggered (TODO)
      sc_proxy1.approval_status.should == 'A'
      UnapprovedRecord.count.should == 1
      put :approve, {:id => sc_proxy2.id}
      UnapprovedRecord.count.should == 0
      sc_proxy1.reload
      sc_proxy1.url.should == "http://example.com"
      sc_proxy1.updated_by.should == "666"
      ScProxy.find_by_id(sc_proxy2.id).should be_nil
    end

    it "(create) unapproved record can be approved" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      sc_proxy = Factory(:sc_proxy, :url => "http://example.com", :approval_status => 'U')
      UnapprovedRecord.count.should == 1
      put :approve, {:id => sc_proxy.id}
      UnapprovedRecord.count.should == 0
      sc_proxy.reload
      sc_proxy.url.should == "http://example.com"
      sc_proxy.approval_status.should == 'A'
    end
  end
end
