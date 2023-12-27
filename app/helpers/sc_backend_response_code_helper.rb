module ScBackendResponseCodeHelper

	def find_sc_backend_response_codes(params)
	sc_backend_response_codes = (params[:approval_status].present? and params[:approval_status] == 'U') ? ScBackendResponseCode.unscoped : ScBackendResponseCode
    sc_backend_response_codes = sc_backend_response_codes.where("LOWER(sc_backend_code) LIKE ?", "%#{params[:sc_backend_code].downcase}%").split(",").collect(&:strip)) if params[:sc_backend_code].present?
    sc_backend_response_codes = sc_backend_response_codes.where("LOWER(sc_backend_code) LIKE ?", "%#{params[:sc_backend_code].downcase}%").split(",").collect(&:strip)) if params[:sc_backend_code].present?
    sc_backend_response_codes
    end

end