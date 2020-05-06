class ScFaultCodesController < ApplicationController
  authorize_resource
  before_filter :authenticate_user!
  before_filter :block_inactive_user!
  respond_to :json
  include ApplicationHelper
  include ScFaultCodeHelper

  def show
    @sc_fault_code = ScFaultCode.find_by_id(params[:id])
    respond_to do |format|
      format.json { render json: @sc_fault_code }
      format.html 
    end 
  end

  def index
    if params[:advanced_search].present?
      sc_fault_codes = find_sc_fault_codes(params).order("id DESC")
    else
      sc_fault_codes = ScFaultCode.order("id desc")
    end
    @sc_fault_codes = sc_fault_codes.paginate(:per_page => 10, :page => params[:page]) rescue []
  end
  
  def get_fault_reason
    sc_fault_code = ScFaultCode.find_by(fault_code: params[:fault_code])
    respond_to do |format|
      format.json { render json: ({reason: sc_fault_code.try(:fault_reason)}) }
    end
  end

  private

  def search_params
    params.permit(:page, :fault_code, :fault_kind)
  end

  def sc_fault_code_params
    params.require(:sc_backend_response_code).permit(:fault_code, :fault_reason, :fault_kind, :occurs_when, :created_at, :updated_at, 
                                                     :remedial_action)
  end
end