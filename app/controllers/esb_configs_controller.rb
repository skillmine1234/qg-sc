class EsbConfigsController < ApplicationController
  #authorize_resource
  before_action :authenticate_user!
  before_action :block_inactive_user!
  respond_to :json
  include EsbConfigHelper

  def index
    if params[:advanced_search].present?
      esb_configs = find_esb_configs(params).order("s_no DESC")
    else
      esb_configs = EsbConfig.order("s_no desc")
    end
    @esb_configs = esb_configs.paginate(:per_page => 10, :page => params[:page]) rescue []
  end

end