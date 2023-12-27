module ScJobHelper

	def find_sc_jobs(params)
    sc_jobs = ScJob.order("id desc")
    sc_jobs = sc_jobs.where("LOWER(code) LIKE ?", "%#{params[:code].downcase}%").split(",").collect(&:strip)) if params[:code].present?
    sc_jobs = sc_jobs.where("LOWER(status_code) LIKE ?", "%#{params[:status_code].downcase}%").split(",").collect(&:strip)) if params[:status_code].present?
    sc_jobs
  end

end