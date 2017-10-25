class ScBackendSettingsController < ApplicationController
  authorize_resource
  before_filter :authenticate_user!
  before_filter :block_inactive_user!
  respond_to :json  
  include ApplicationHelper
  include Approval2::ControllerAdditions
  
  def new
    @sc_backend_setting = ScBackendSetting.new
  end

  def create
    @sc_backend_setting = ScBackendSetting.new(params[:sc_backend_setting])
    if !@sc_backend_setting.valid?
      render "new"
    else
      @sc_backend_setting.created_by = current_user.id
      @sc_backend_setting.save!
      flash[:alert] = "Setting successfully created is pending for approval"
      redirect_to @sc_backend_setting
    end
  end

  def update
    @sc_backend_setting = ScBackendSetting.unscoped.find_by_id(params[:id])
    @sc_backend_setting.attributes = params[:sc_backend_setting]
    if !@sc_backend_setting.valid?
      render "edit"
    else
      @sc_backend_setting.updated_by = current_user.id
      @sc_backend_setting.save!
      flash[:alert] = 'Setting successfully modified and is pending for approval'
      redirect_to @sc_backend_setting
    end
    rescue ActiveRecord::StaleObjectError
      @sc_backend_setting.reload
      flash[:alert] = 'Someone edited the record the same time you did. Please re-apply your changes to the record.'
      render "edit"
  end

  def show
    @sc_backend_setting = ScBackendSetting.unscoped.find_by_id(params[:id])
  end
  
  def index
    if request.get?
      @searcher = ScBackendSettingSearcher.new(params.permit(:approval_status, :page))
    else
      @searcher = ScBackendSettingSearcher.new(search_params)
    end
    @records = @searcher.paginate
  end

  def audit_logs
    @record = ScBackendSetting.unscoped.find(params[:id]) rescue nil
    @audit = @record.audits[params[:version_id].to_i] rescue nil
  end
  
  def get_service_codes
    @service_codes = ScBackendSetting.where(app_id: nil, backend_code: params[:backend_code]).pluck(:service_code)
    respond_to do |format|
      format.json { render json: @service_codes }
    end
  end
  
  def settings
    @sc_backend_setting = ScBackendSetting.find_by(app_id: nil, backend_code: params[:backend_code], service_code: params[:service_code])
    respond_to do |format|
      format.js
    end
  end
  
  def approve
    redirect_to unapproved_records_path(group_name: 'sc-backend')
  end

  private

  def search_params
    params.permit(:page, :backend_code, :service_code, :app_id, :approval_status)
  end

  def sc_backend_setting_params
    params.require(:sc_backend_setting).permit(:backend_code, :service_code, :app_id, :settings_cnt,
    :setting1_name, :setting1_type, :setting1_value, 
    :setting2_name, :setting2_type, :setting2_value, 
    :setting3_name, :setting3_type, :setting3_value, 
    :setting4_name, :setting4_type, :setting4_value,
    :setting5_name, :setting5_type, :setting5_value,
    :setting6_name, :setting6_type, :setting6_value, 
    :setting7_name, :setting7_type, :setting7_value, 
    :setting8_name, :setting8_type, :setting8_value, 
    :setting9_name, :setting9_type, :setting9_value,
    :setting10_name, :setting10_type, :setting10_value,
    :created_at, :updated_at, :created_by, :updated_by, :lock_version, :approved_id, :approved_version, :last_action,
    :is_std, :is_enabled)
  end
end