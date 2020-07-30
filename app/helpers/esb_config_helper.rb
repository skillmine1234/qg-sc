module EsbConfigHelper

	def find_esb_configs(params)
		esb_configs = EsbConfig.all
    esb_configs = esb_configs.where("s_no = ?", params[:s_no]) if params[:s_no].present?
    esb_configs = esb_configs.where("key IN (?)", params[:key].split(",").collect(&:strip)) if params[:key].present?
    esb_configs = esb_configs.where("value IN (?)", params[:value].split(",").collect(&:strip)) if params[:value].present?
    esb_configs
  end

end