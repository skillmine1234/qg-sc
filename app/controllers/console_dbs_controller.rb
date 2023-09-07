class ConsoleDbsController < ApplicationController
  require 'csv'

  #authorize_resource
  require 'will_paginate/array'
  before_filter :authenticate_user!
  before_filter :block_inactive_user!
  respond_to :json

  def fault_code_master

    if params[:advanced_search].present?
      @fault_code_master = FaultCodeMaster.order("id desc")
      @fault_code_master = @fault_code_master.where("lower(fault_code) LIKE ?","%#{params[:fault_code].downcase}%") if params[:fault_code].present?
      @fault_code_master = @fault_code_master.where("lower(status_code) LIKE ?", "%#{params[:status_code]}%") if params[:status_code].present?
      @fault_code_master = @fault_code_master.where("lower(sub_code) LIKE ?","%#{params[:sub_code]}%") if params[:sub_code].present?
      @fault_code_master
    else
      @fault_code_master = FaultCodeMaster.all
    end  
    @fault_code_master = @fault_code_master.paginate(:per_page => 25, :page => params[:page]) rescue []
  end

  def fault_code_cust_stats
    if params[:advanced_search].present?
      @fault_code_stats = FaultCodeCustStat.order("id desc")
      @fault_code_stats = @fault_code_stats.where("lower(fault_code_id) LIKE ?","%#{params[:fault_code_id]}%") if params[:fault_code_id].present?
      @fault_code_stats = @fault_code_stats.where("lower(customer_code) LIKE ?", "%#{params[:customer_code]}%") if params[:customer_code].present?
      @fault_code_stats = @fault_code_stats.where("lower(source_app) LIKE ?", "%#{params[:source_app]}%") if params[:source_app].present?
    else
       @fault_code_stats = FaultCodeCustStat.all
    end

   
    @fault_code_stats = @fault_code_stats.paginate(:per_page => 25, :page => params[:page]) rescue []
  end

  def download_fault_code_master
    table = FaultCodeMaster.all

    col_seperartor = ","
    csv_string = CSV.generate(:col_sep => "#{col_seperartor}") do |csv|
      csv << ["Fault Code","Description","Reason","Resolution","Status Code","Sub Code","Source App","Error Classification","Remarks"]
      table.each do |record|
        csv << [record.fault_code,record.description,record.reason,record.resolution,record.status_code,record.sub_code,record.source_app,record.error_classification,record.remarks]
      end
    end 
    send_data csv_string, :type => 'text/csv; charset=utf-8; header=present', :disposition => "attachment; filename=Master_Fault_code_data_#{Time.now.strftime('%d-%m-%Y')}.csv"
  end

  def download_fault_code_cust_stats
    table = FaultCodeCustStat.all

    col_seperartor = ","
     csv_string = CSV.generate(:col_sep => "#{col_seperartor}") do |csv|
      csv << ["Faul Code ID","Customer Code","Source App","Fault Date","Fault Count","Transaction Status"]
      table.each do |record|
        csv << [record.fault_code_id,record.customer_code,record.source_app,record.fault_date,record.fault_count,record.transaction_status]
      end
    end 
    send_data csv_string, :type => 'text/csv; charset=utf-8; header=present', :disposition => "attachment; filename=Customer_wise_Fault_code_data_#{Time.now.strftime('%d-%m-%Y')}.csv"
  end

end