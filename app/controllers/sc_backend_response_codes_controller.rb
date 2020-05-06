class ScBackendResponseCodesController < ApplicationController
  authorize_resource
  before_filter :authenticate_user!
  before_filter :block_inactive_user!
  respond_to :json  
  include ApplicationHelper
  include Approval2::ControllerAdditions
  include ScBackendResponseCodeHelper
  
  def new
    @sc_backend_response_code = ScBackendResponseCode.new
  end

  def create
    @sc_backend_response_code = ScBackendResponseCode.new(params[:sc_backend_response_code])
    if !@sc_backend_response_code.valid?
      render "new"
    else
      @sc_backend_response_code.created_by = current_user.id
      @sc_backend_response_code.save!
      flash[:alert] = "Code successfully created is pending for approval"
      redirect_to @sc_backend_response_code
    end
  end

  def update
    @sc_backend_response_code = ScBackendResponseCode.unscoped.find_by_id(params[:id])
    @sc_backend_response_code.attributes = params[:sc_backend_response_code]
    if !@sc_backend_response_code.valid?
      render "edit"
    else
      @sc_backend_response_code.updated_by = current_user.id
      @sc_backend_response_code.save!
      flash[:alert] = 'Code successfully modified and is pending for approval'
      redirect_to @sc_backend_response_code
    end
    rescue ActiveRecord::StaleObjectError
      @sc_backend_response_code.reload
      flash[:alert] = 'Someone edited the code the same time you did. Please re-apply your changes to the code.'
      render "edit"
  end

  def show
    @sc_backend_response_code = ScBackendResponseCode.unscoped.find_by_id(params[:id])
  end
  

  def index
    if params[:advanced_search].present?
      sc_backend_response_codes = find_sc_backend_response_codes(params).order("id DESC")
    else
      sc_backend_response_codes = (params[:approval_status].present? and params[:approval_status] == 'U') ? ScBackendResponseCode.unscoped.where("approval_status =?",'U').order("id desc") : ScBackendResponseCode.order("id desc")
    end
    @sc_backend_response_codes = sc_backend_response_codes.paginate(:per_page => 10, :page => params[:page]) rescue []
  end

  def audit_logs
    @sc_backend_response_code = ScBackendResponseCode.unscoped.find(params[:id]) rescue nil
    @audit = @sc_backend_response_code.audits[params[:version_id].to_i] rescue nil
  end
  
  def approve
    redirect_to unapproved_records_path(group_name: 'sc-backend')
  end

  private

  def search_params
    params.permit(:page, :sc_backend_code, :response_code, :approval_status)
  end

  def sc_backend_response_code_params
    params.require(:sc_backend_response_code).permit(:is_enabled, :sc_backend_code, :response_code, :fault_code, :created_at, :updated_at, 
                                                     :created_by, :updated_by, :lock_version, :approved_id, :approved_version, :lock_version)
  end
end