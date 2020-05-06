class ScServicesController < ApplicationController
  authorize_resource
  before_filter :authenticate_user!
  before_filter :block_inactive_user!
  respond_to :json
  include Approval2::ControllerAdditions
  include ApplicationHelper
  include ScServiceHelper

  def create
    @sc_service = ScService.new(sc_service_params)
    if !@sc_service.valid?
      render "edit"
    else
      @sc_service.created_by = current_user.id
      @sc_service.save!
      flash[:alert] = 'ScService successfully created and is pending for approval'
      redirect_to @sc_service
    end
  end

  def update
    @sc_service = ScService.unscoped.find_by_id(params[:id])
    @sc_service.attributes = params[:sc_service]
    if !@sc_service.valid?
      render "edit"
    else
      @sc_service.updated_by = current_user.id
      @sc_service.save!
      flash[:alert] = 'ScService modified successfully and is pending for approval'
      redirect_to @sc_service
    end
    rescue ActiveRecord::StaleObjectError
      @sc_service.reload
      flash[:alert] = 'Someone edited the sc_service the same time you did. Please re-apply your changes to the sc_service.'
      render "edit"
  end 

  def show
    @sc_service = ScService.unscoped.find_by_id(params[:id])
  end

  def index
    if params[:advanced_search].present?
      sc_services = find_sc_services(params).order("id DESC")
    else
      sc_services = (params[:approval_status].present? and params[:approval_status] == 'U') ? ScService.unscoped.where("approval_status =?",'U').order("id desc") : ScService.order("id desc")
    end
    @sc_services = sc_services.paginate(:per_page => 10, :page => params[:page]) rescue []
  end

  def audit_logs
    @record = ScService.unscoped.find(params[:id]) rescue nil
    @audit = @record.audits[params[:version_id].to_i] rescue nil
  end

  def approve
    redirect_to unapproved_records_path(group_name: 'sc-backend')
  end

  private    

  def sc_service_params
    params.require(:sc_service).permit(:code, :name, :url, :use_proxy, :http_username, :http_password, :created_by, :updated_by, :lock_version, :last_action, 
                                      :approval_status, :approved_version, :approved_id)
  end
  
  def search_params
    params.require(:sc_service_searcher).permit(:page, :code, :approval_status)
  end
end
