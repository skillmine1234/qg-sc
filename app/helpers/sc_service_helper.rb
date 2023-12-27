module ScServiceHelper

	def find_sc_services(params)
    sc_services = (params[:approval_status].present? and params[:approval_status] == 'U') ? ScService.unscoped : ScService
    sc_services = sc_services.where("LOWER(code) LIKE ?", "%#{params[:code].downcase}%").split(",").collect(&:strip)) if params[:code].present?
    sc_services
  end

end