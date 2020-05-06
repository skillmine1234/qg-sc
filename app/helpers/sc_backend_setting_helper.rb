module ScBackendSettingHelper

	def find_sc_backend_settings(params)
		sc_backend_settings = (params[:approval_status].present? and params[:approval_status] == 'U') ? ScBackendSetting.unscoped : ScBackendSetting
    sc_backend_settings = sc_backend_settings.where("backend_code IN (?)", params[:backend_code].split(",").collect(&:strip)) if params[:backend_code].present?
    sc_backend_settings = sc_backend_settings.where("service_code IN (?)", params[:service_code].split(",").collect(&:strip)) if params[:service_code].present?
    sc_backend_settings = sc_backend_settings.where("app_id IN (?)", params[:app_id].split(",").collect(&:strip)) if params[:app_id].present?
    sc_backend_settings
  end

end