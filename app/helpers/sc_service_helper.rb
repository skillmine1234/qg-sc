module ScServiceHelper

	def find_sc_services(params)
    sc_services = (params[:approval_status].present? and params[:approval_status] == 'U') ? ScService.unscoped : ScService
    sc_services = sc_services.where("code IN (?)", params[:code].split(",").collect(&:strip)) if params[:code].present?
    sc_services
  end

end