class ScJobsController < ApplicationController
  ##authorize_resource
  before_action :authenticate_user!
  before_action :block_inactive_user!
  respond_to :json
  include ApplicationHelper
  include ScJobHelper

  def index
    if params[:advanced_search].present?
      sc_jobs = find_sc_jobs(params).order("id DESC")
    else
      sc_jobs = ScJob.order("id desc")
    end
    @sc_jobs = sc_jobs.paginate(:per_page => 10, :page => params[:page]) rescue []
  end

  def show
    @sc_job = ScJob.find(params[:id])
  end
  
  def run
    sc_job = ScJob.find(params[:id])
    ActiveRecord::Base.transaction do
      if sc_job.run_now == 'N'
        sc_job.update_column(:run_now, 'Y')
        sc_job.update_column(:paused, 'N')
        flash[:alert] = 'Your job will start now!'
      end
    end
  rescue ::ActiveRecord::ActiveRecordError => e
    flash[:alert] = e.message
  ensure
    redirect_to sc_jobs_path
  end
  
  def pause
    sc_job = ScJob.find(params[:id])
    ActiveRecord::Base.transaction do
      if sc_job.paused == 'N'
        sc_job.update_column(:paused, 'Y')
        sc_job.update_column(:run_now, 'N')
        flash[:alert] = 'Your job is paused now!'
      end
    end
  rescue ::ActiveRecord::ActiveRecordError => e
    flash[:alert] = e.message
  ensure
    redirect_to sc_jobs_path
  end

  private

  def search_params
    params.permit(:page, :code, :status_code)
  end
end
