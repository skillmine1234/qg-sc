module ScBackendResponseCodeHelper

	def find_sc_backend_response_codes(params)
		sc_backend_response_codes = (params[:approval_status].present? and params[:approval_status] == 'U') ? ScBackendResponseCode.unscoped : ScBackendResponseCode
    sc_backend_response_codes = sc_fault_codes.where("sc_backend_code IN (?)", params[:sc_backend_code].split(",").collect(&:strip)) if params[:sc_backend_code].present?
    sc_backend_response_codes = sc_fault_codes.where("response_code IN (?)", params[:response_code].split(",").collect(&:strip)) if params[:response_code].present?
    sc_backend_response_codes
  end

end