class ScProxiesController < ApplicationController
  #authorize_resource
  before_action :authenticate_user!
  before_action :block_inactive_user!
  respond_to :json
  include Approval2::ControllerAdditions
  include ApplicationHelper

  def create
    @sc_proxy = ScProxy.new(sc_proxy_params)
    if !@sc_proxy.valid?
      render "edit"
    else
      @sc_proxy.created_by = current_user.id
      @sc_proxy.save!
      flash[:alert] = 'ScProxy successfully created and is pending for approval'
      redirect_to @sc_proxy
    end
  end

  def update
    @sc_proxy = ScProxy.unscoped.find_by_id(params[:id])
    @sc_proxy.attributes = params[:sc_proxy]
    if !@sc_proxy.valid?
      render "edit"
    else
      @sc_proxy.updated_by = current_user.id
      @sc_proxy.save!
      flash[:alert] = 'ScProxy modified successfully'
      redirect_to @sc_proxy
    end
    rescue ActiveRecord::StaleObjectError
      @sc_proxy.reload
      flash[:alert] = 'Someone edited the rule the same time you did. Please re-apply your changes to the rule.'
      render "edit"
  end 

  def show
    @sc_proxy = ScProxy.unscoped.find_by_id(params[:id])
  end

  def index
    sc_proxies = ScProxy.unscoped.where("approval_status=?",'U').order("id desc")
    @sc_proxies_count = sc_proxies.count
    @sc_proxies = sc_proxies.paginate(:per_page => 10, :page => params[:page]) rescue []
  end

  def audit_logs
    @record = ScProxy.unscoped.find(params[:id]) rescue nil
    @audit = @record.audits[params[:version_id].to_i] rescue nil
  end

  def approve
    redirect_to unapproved_records_path(group_name: 'sc-backend')
  end

  private    

  def sc_proxy_params
    params.require(:sc_proxy).permit(:url, :username, :password, :is_enabled, :created_by, :updated_by, :lock_version, :last_action, 
                                    :approval_status, :approved_version, :approved_id)
  end
end
