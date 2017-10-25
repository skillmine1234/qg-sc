require 'spec_helper'

describe ScBackendsController do
  include HelperMethods
  
  before(:each) do
    @controller.instance_eval { flash.extend(DisableFlashSweeping) }
    sign_in @user = Factory(:user)
    Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'editor').id)
    request.env["HTTP_REFERER"] = "/"
  end

  describe "GET index" do
    it "assigns all sc_backends as @sc_backends" do
      sc_backend = Factory(:sc_backend, :approval_status => 'A')
      get :index
      assigns(:sc_backends).should eq([sc_backend])
    end

    it "assigns all unapproved sc_backends as @sc_backends when approval_status is passed" do
      sc_backend = Factory(:sc_backend, :approval_status => 'U')
      get :index, :approval_status => 'U'
      assigns(:sc_backends).should eq([sc_backend])
    end
  end

  describe "GET show" do
    it "assigns the requested sc_backend as @sc_backend" do
      sc_backend = Factory(:sc_backend)
      get :show, {:id => sc_backend.id}
      assigns(:sc_backend).should eq(sc_backend)
    end
  end

  describe "GET previous_status_changes" do
    it "should return @previous_status_changes for @sc_backend if present" do
      sc_backend = Factory(:sc_backend, :code => '6545')
      sc_backend_status_change1 = Factory(:sc_backend_status_change, :code => '6545', :new_status => 'A', :created_at => '2016-10-28 15:05:00')
      sc_backend_status_change2 = Factory(:sc_backend_status_change, :code => '6545', :new_status => 'B', :created_at => '2016-10-28 15:06:00')
      sc_backend_status_change3 = Factory(:sc_backend_status_change, :code => '6545', :new_status => 'C', :created_at => '2016-10-28 15:07:00')
      get :previous_status_changes, {:id => sc_backend.id}
      assigns(:previous_status_changes).should eq([sc_backend_status_change3, sc_backend_status_change2, sc_backend_status_change1])
    end
  end

  describe "GET new" do
    it "assigns a new sc_backend as @sc_backend" do
      get :new
      assigns(:sc_backend).should be_a_new(ScBackend)
    end
  end

  describe "GET edit" do
    it "assigns the requested sc_backend with status 'U' as @sc_backend" do
      sc_backend = Factory(:sc_backend, :approval_status => 'U')
      get :edit, {:id => sc_backend.id}
      assigns(:sc_backend).should eq(sc_backend)
    end

    it "assigns the requested sc_backend with status 'A' as @sc_backend" do
      sc_backend = Factory(:sc_backend, :approval_status => 'A')
      get :edit, {:id => sc_backend.id}
      assigns(:sc_backend).should eq(sc_backend)
    end

    it "assigns the new sc_backend with requested sc_backend params when status 'A' as @sc_backend" do
      sc_backend = Factory(:sc_backend, :approval_status => 'A')
      params = (sc_backend.attributes).merge({:approved_id => sc_backend.id, :approved_version => sc_backend.lock_version})
      get :edit, {:id => sc_backend.id}
      assigns(:sc_backend).should eq(ScBackend.new(params))
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new sc_backend" do
        params = Factory.attributes_for(:sc_backend)
        expect {
          post :create, {:sc_backend => params}
        }.to change(ScBackend.unscoped, :count).by(1)
        flash[:alert].should  match(/SC Backend successfully created and is pending for approval/)
        response.should be_redirect
      end

      it "assigns a newly created sc_backend as @sc_backend" do
        params = Factory.attributes_for(:sc_backend)
        post :create, {:sc_backend => params}
        assigns(:sc_backend).should be_a(ScBackend)
        assigns(:sc_backend).should be_persisted
      end

      it "redirects to the created sc_backend" do
        params = Factory.attributes_for(:sc_backend)
        post :create, {:sc_backend => params}
        response.should redirect_to(ScBackend.unscoped.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved sc_backend as @sc_backend" do
        params = Factory.attributes_for(:sc_backend)
        params[:code] = nil
        expect {
          post :create, {:sc_backend => params}
        }.to change(ScBackend, :count).by(0)
        assigns(:sc_backend).should be_a(ScBackend)
        assigns(:sc_backend).should_not be_persisted
      end

      it "re-renders the 'new' template when show_errors is true" do
        params = Factory.attributes_for(:sc_backend)
        params[:code] = nil
        post :create, {:sc_backend => params}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested sc_backend" do
        sc_backend = Factory(:sc_backend, :code => "7766")
        params = sc_backend.attributes.slice(*sc_backend.class.attribute_names)
        params[:code] = "7767"
        put :update, {:id => sc_backend.id, :sc_backend => params}
        sc_backend.reload
        sc_backend.code.should == "7767"
      end

      it "assigns the requested sc_backend as @sc_backend" do
        sc_backend = Factory(:sc_backend, :code => "7768")
        params = sc_backend.attributes.slice(*sc_backend.class.attribute_names)
        params[:code] = "7768"
        put :update, {:id => sc_backend.to_param, :sc_backend => params}
        assigns(:sc_backend).should eq(sc_backend)
      end

      it "redirects to the sc_backend" do
        sc_backend = Factory(:sc_backend, :code => "7769")
        params = sc_backend.attributes.slice(*sc_backend.class.attribute_names)
        params[:code] = "7769"
        put :update, {:id => sc_backend.to_param, :sc_backend => params}
        response.should redirect_to(sc_backend)
      end

      it "should raise error when tried to update at same time by many" do
        sc_backend = Factory(:sc_backend, :code => "7770")
        params = sc_backend.attributes.slice(*sc_backend.class.attribute_names)
        params[:code] = "7770"
        sc_backend2 = sc_backend
        put :update, {:id => sc_backend.id, :sc_backend => params}
        sc_backend.reload
        sc_backend.code.should == "7770"
        params[:code] = "7771"
        put :update, {:id => sc_backend2.id, :sc_backend => params}
        sc_backend.reload
        sc_backend.code.should == "7770"
        flash[:alert].should  match(/Someone edited the SC Backend the same time you did. Please re-apply your changes to the SC Backend/)
      end
    end

    describe "with invalid params" do
      it "assigns the sc_backend as @sc_backend" do
        sc_backend = Factory(:sc_backend, :code => "7771")
        params = sc_backend.attributes.slice(*sc_backend.class.attribute_names)
        params[:code] = nil
        put :update, {:id => sc_backend.to_param, :sc_backend => params}
        assigns(:sc_backend).should eq(sc_backend)
        sc_backend.reload
        params[:code] = nil
      end

      it "re-renders the 'edit' template when show_errors is true" do
        sc_backend = Factory(:sc_backend)
        params = sc_backend.attributes.slice(*sc_backend.class.attribute_names)
        params[:code] = nil
        put :update, {:id => sc_backend.id, :sc_backend => params, :show_errors => "true"}
        response.should render_template("edit")
      end
    end
  end
 
  describe "GET audit_logs" do
    it "assigns the requested sc_backend as @sc_backend" do
      sc_backend = Factory(:sc_backend)
      get :audit_logs, {:id => sc_backend.id, :version_id => 0}
      assigns(:sc_backend).should eq(sc_backend)
      assigns(:audit).should eq(sc_backend.audits.first)
      get :audit_logs, {:id => 12345, :version_id => "i"}
      assigns(:sc_backend).should eq(nil)
      assigns(:audit).should eq(nil)
    end
  end

  describe "PUT approve" do
    it "(edit) unapproved record can be approved and old approved record will be updated" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      sc_backend1 = Factory(:sc_backend, :approval_status => 'A')
      sc_backend2 = Factory(:sc_backend, :approval_status => 'U', :code => '7772', :approved_version => sc_backend1.lock_version, :approved_id => sc_backend1.id, :created_by => 666)
      # the following line is required for reload to get triggered (TODO)
      sc_backend1.approval_status.should == 'A'
      UnapprovedRecord.count.should == 1
      put :approve, {:id => sc_backend2.id}
      UnapprovedRecord.count.should == 0
      sc_backend1.reload
      sc_backend1.code.should == '7772'
      sc_backend1.updated_by.should == "666"
      UnapprovedRecord.find_by_id(sc_backend2.id).should be_nil
    end

    it "(create) unapproved record can be approved" do
      user_role = UserRole.find_by_user_id(@user.id)
      user_role.delete
      Factory(:user_role, :user_id => @user.id, :role_id => Factory(:role, :name => 'supervisor').id)
      sc_backend = Factory(:sc_backend, :code => '7772', :approval_status => 'U')
      UnapprovedRecord.count.should == 1
      put :approve, {:id => sc_backend.id}
      UnapprovedRecord.count.should == 0
      sc_backend.reload
      sc_backend.code.should == '7772'
      sc_backend.approval_status.should == 'A'
    end
  end

  describe "POST change_status" do
    describe "with valid params" do
      it "updates the requested sc_backend to Up" do
        sc_backend = Factory(:sc_backend, :code => "7766")
        sc_backend_stat = Factory(:sc_backend_stat, :code => sc_backend.code, :window_success_cnt => 9, :consecutive_failure_cnt => 8,
                                  :window_failure_cnt => 10)
        sc_backend_status = Factory(:sc_backend_status, :status => 'D', :code => sc_backend.code)
        params = sc_backend.attributes.slice(*sc_backend.class.attribute_names)
        params[:code] = "7767"
        post :change_status, {:id => sc_backend.id, :sc_backend_status_change => {:remarks => "Test"}}
        sc_backend_stat.reload
        sc_backend_status.reload
        ScBackendStatusChange.last.remarks.should == 'Test'
        sc_backend_stat.last_status_change_id.should == ScBackendStatusChange.last.id
        sc_backend_status.last_status_change_id.should == ScBackendStatusChange.last.id
        sc_backend_status.status.should == 'U'
        sc_backend_stat.window_success_cnt.should == 0
        sc_backend_stat.consecutive_failure_cnt.should == 0
        sc_backend_stat.window_failure_cnt.should == 0
      end

      it "updates the requested sc_backend to Down" do
        sc_backend = Factory(:sc_backend, :code => "7766")
        sc_backend_stat = Factory(:sc_backend_stat, :code => sc_backend.code, :window_success_cnt => 9, :consecutive_failure_cnt => 8,
                                  :window_failure_cnt => 10)
        sc_backend_status = Factory(:sc_backend_status, :status => 'U', :code => sc_backend.code)
        params = sc_backend.attributes.slice(*sc_backend.class.attribute_names)
        params[:code] = "7767"
        post :change_status, {:id => sc_backend.id, :sc_backend_status_change => {:remarks => "Test"}}
        sc_backend_stat.reload
        sc_backend_status.reload
        ScBackendStatusChange.last.remarks.should == 'Test'
        sc_backend_stat.last_status_change_id.should == ScBackendStatusChange.last.id
        sc_backend_status.last_status_change_id.should == ScBackendStatusChange.last.id
        sc_backend_status.status.should == 'D'
        sc_backend_stat.window_success_cnt.should == 9
        sc_backend_stat.window_failure_cnt.should == 10 
        sc_backend_stat.consecutive_failure_cnt.should == 8
      end

      it "shows errors on failure" do
        sc_backend = Factory(:sc_backend, :code => "7766")
        sc_backend_stat = Factory(:sc_backend_stat, :code => sc_backend.code, :last_status_change_id => nil)
        sc_backend_status = Factory(:sc_backend_status, :code => sc_backend.code, :status => 'A', :last_status_change_id => nil)
        params = sc_backend.attributes.slice(*sc_backend.class.attribute_names)
        params[:code] = "7767"
        post :change_status, {:id => sc_backend.id, :sc_backend_status_change => {:remarks => "Test"}}
        sc_backend_stat.reload
        sc_backend_status.reload
        flash[:alert].should == "New status can't be blank,New status is too short (minimum is 1 character)"
        ScBackendStatusChange.last.should be_nil
        sc_backend_stat.last_status_change_id.should be_nil
        sc_backend_status.last_status_change_id.should be_nil
      end
    end
  end
end
