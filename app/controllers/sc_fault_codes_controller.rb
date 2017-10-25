class ScFaultCodesController < ApplicationController
  authorize_resource
  before_filter :authenticate_user!
  before_filter :block_inactive_user!
  respond_to :json
  include ApplicationHelper

  def show
    @sc_fault_code = ScFaultCode.find_by_id(params[:id])
    respond_to do |format|
      format.json { render json: @sc_fault_code }
      format.html 
    end 
  end
  
  def index
    if request.get?
      @searcher = ScFaultCodeSearcher.new(params.permit(:page))
    else
      @searcher = ScFaultCodeSearcher.new(search_params)
    end
    @records = @searcher.paginate
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