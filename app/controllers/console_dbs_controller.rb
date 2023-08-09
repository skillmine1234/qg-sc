class ConsoleDbsController < ApplicationController
  # authorize_resource
  require 'will_paginate/array'
  before_filter :authenticate_user!
  before_filter :block_inactive_user!
  respond_to :json

  def fault_code_master
    @fault_code_master = FaultCodeMaster.all
    @fault_code_master = @fault_code_master.paginate(:per_page => 1, :page => params[:page]) rescue []

  end

  def fault_code_cust_stats
    @fault_code_stats = FaultCodeCustStat.all
    @fault_code_stats = @fault_code_stats.paginate(:per_page => 1, :page => params[:page]) rescue []
  end

end