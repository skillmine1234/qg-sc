module ScBackendSettingHelper

	def find_sc_backend_settings(params)
	sc_backend_settings = (params[:approval_status].present? and params[:approval_status] == 'U') ? ScBackendSetting.unscoped : ScBackendSetting
    sc_backend_settings = sc_backend_settings.where("LOWER(backend_code) LIKE ?", "%#{params[:backend_code].downcase}%").split(",").collect(&:strip)) if params[:backend_code].present?
    sc_backend_settings = sc_backend_settings.where("LOWER(service_code) LIKE ?", "%#{params[:service_code].downcase}%").split(",").collect(&:strip)) if params[:service_code].present?
    sc_backend_settings = sc_backend_settings.where("LOWER(app_id) LIKE ?", "%#{params[:app_id].downcase}%").split(",").collect(&:strip)) if params[:app_id].present?
    sc_backend_settings
  end

end