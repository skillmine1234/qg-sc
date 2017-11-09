class ScJobsController < ApplicationController
  authorize_resource
  before_filter :authenticate_user!
  before_filter :block_inactive_user!
  respond_to :json
  include ApplicationHelper

  def index
    if request.get?
      @searcher = ScJobSearcher.new(params.permit(:page))
    else
      @searcher = ScJobSearcher.new(search_params)
    end
    @records = @searcher.paginate
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
