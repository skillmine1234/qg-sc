module ScFaultCodeHelper

	def find_sc_fault_codes(params)
    sc_fault_codes = ScFaultCode.order("id desc")
    sc_fault_codes = sc_backend_settings.where("LOWER(fault_code) LIKE ?", "%#{params[:fault_code].downcase}%").split(",").collect(&:strip)) if params[:fault_code].present?
    sc_fault_codes
    end

end