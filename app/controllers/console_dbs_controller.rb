class ConsoleDbsController < ApplicationController
  # authorize_resource
  require 'will_paginate/array'
  before_filter :authenticate_user!
  before_filter :block_inactive_user!
  respond_to :json

  def fault_code_master
    if params[:advanced_search].present?
      @fault_code_master = FaultCodeMaster.order("id desc")
      @fault_code_master = @fault_code_master.where("fault_code LIKE ?","%#{params[:fault_code]}%") if params[:fault_code].present?
      @fault_code_master = @fault_code_master.where("stauts_code LIKE ?", "%#{params[:status_code]}%") if params[:status_code].present?
      @fault_code_master = @fault_code_master.where("sub_code LIKE ?","%#{params[:sub_code]}%") if params[:sub_code].present?
      @fault_code_master
    else
      @fault_code_master = FaultCodeMaster.all
    end  
    @fault_code_master = @fault_code_master.paginate(:per_page => 25, :page => params[:page]) rescue []
  end

  def fault_code_cust_stats
    if params[:advanced_search].present?
      @fault_code_stats = FaultCodeCustStat.order("id desc")
      @fault_code_stats = @fault_code_stats.where("fault_code_id LIKE ?","%#{params[:fault_code_id]}%") if params[:fault_code_id].present?
      @fault_code_stats = @fault_code_stats.where("customer_code LIKE ?", "%#{params[:customer_code]}%") if params[:customer_code].present?
      @fault_code_stats = @fault_code_stats.where("source_app LIKE ?", "%#{params[:source_app]}%") if params[:source_app].present?
    else
       @fault_code_stats = FaultCodeCustStat.all
    end

   
    @fault_code_stats = @fault_code_stats.paginate(:per_page => 25, :page => params[:page]) rescue []
  end

end