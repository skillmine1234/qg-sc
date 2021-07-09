class ScFaultCodesController < ApplicationController
  authorize_resource
  before_filter :authenticate_user!
  before_filter :block_inactive_user!
  respond_to :json
  include Approval2::ControllerAdditions
  include ApplicationHelper
  include ScFaultCodeHelper

  def new
    @sc_fault_code = ScFaultCode.new
  end

  def create
    @sc_fault_code = ScFaultCode.new(sc_fault_code_params)
    if !@sc_fault_code.valid?
      render "new"
    else
      @sc_fault_code.created_by = current_user.id
      @sc_fault_code.save!
      flash[:alert] = "Fault Code successfully created and is pending for approval"
      redirect_to @sc_fault_code
    end
  end

  def update
    @sc_fault_code = ScFaultCode.unscoped.find_by_id(params[:id])
    @sc_fault_code.attributes = params[:sc_fault_code]
    if !@sc_fault_code.valid?
      render "edit"
    else
      @sc_fault_code.updated_by = current_user.id
      @sc_fault_code.save!
      flash[:alert] = 'Fault Code successfully modified and is pending for approval'
      redirect_to @sc_fault_code
    end
    rescue ActiveRecord::StaleObjectError
      @sc_fault_code.reload
      flash[:alert] = 'Someone edited the record the same time you did. Please re-apply your changes to the record.'
      render "edit"
  end

  def show
    @sc_fault_code = ScFaultCode.unscoped.find_by_id(params[:id])
    respond_to do |format|
      format.json { render json: @sc_fault_code }
      format.html 
    end 
  end

  def index
    if params[:advanced_search].present?
      sc_fault_codes = find_sc_fault_codes(params).order("id DESC")
    else
      sc_fault_codes = (params[:approval_status].present? and params[:approval_status] == 'U') ? ScFaultCode.unscoped.where("approval_status =?",'U').order("id desc") : ScFaultCode.order("id desc")
    end
    @sc_fault_codes = sc_fault_codes.paginate(:per_page => 10, :page => params[:page]) rescue []
  end
  
  def get_fault_reason
    sc_fault_code = ScFaultCode.find_by(fault_code: params[:fault_code])
    respond_to do |format|
      format.json { render json: ({reason: sc_fault_code.try(:fault_reason)}) }
    end
  end

  def approve
    redirect_to unapproved_records_path(group_name: 'sc-backend')
  end


  private

  def search_params
    params.permit(:page, :fault_code, :fault_kind)
  end

  def sc_fault_code_params
    params.require(:sc_fault_code).permit(:fault_code, :fault_reason, :fault_kind, :occurs_when, :created_at, :updated_at, 
                                                     :remedial_action,:created_by,:updated_by)
  end
  
end