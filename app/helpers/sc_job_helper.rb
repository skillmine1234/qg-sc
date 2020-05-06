module ScJobHelper

	def find_sc_jobs(params)
    sc_jobs = ScJob.order("id desc")
    sc_jobs = sc_jobs.where("code IN (?)", params[:code].split(",").collect(&:strip)) if params[:code].present?
    sc_jobs = sc_jobs.where("status_code IN (?)", params[:status_code].split(",").collect(&:strip)) if params[:status_code].present?
    sc_jobs
  end

end