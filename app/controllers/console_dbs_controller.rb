class ConsoleDbsController < ApplicationController
  #authorize_resource
  before_filter :authenticate_user!
  before_filter :block_inactive_user!
  respond_to :json

  def fault_code_master
    @fault_code_master = FaultCodeMaster.all
  end

  def fault_code_cust_stats
    @fault_code_stats = FaultCodeCustStat.all
  end

end