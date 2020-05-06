module ScFaultCodeHelper

	def find_sc_fault_codes(params)
    sc_fault_codes = ScFaultCode.order("id desc")
    sc_fault_codes = sc_fault_codes.where("fault_code IN (?)", params[:fault_code].split(",").collect(&:strip)) if params[:fault_code].present?
    sc_fault_codes = sc_fault_codes.where("fault_kind IN (?)", params[:fault_kind].split(",").collect(&:strip)) if params[:fault_kind].present?
    sc_fault_codes
  end

end