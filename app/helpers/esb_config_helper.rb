module EsbConfigHelper

	def find_esb_configs(params)
		esb_configs = EsbConfig.all
 esb_configs = esb_configs.where("LOWER(s_no) LIKE ?", "%#{params[:s_no].downcase}%") if params[:s_no].present?
    esb_configs = esb_configs.where("LOWER(key) LIKE ?", "%#{params[:key].downcase}%") if params[:key].present?
    esb_configs = esb_configs.where("LOWER(value) LIKE ?", "%#{params[:value].downcase}%") if params[:value].present?
    esb_configs
  end

end