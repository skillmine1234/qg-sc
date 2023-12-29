class ScBackendsController < ApplicationController
  #authorize_resource
  before_action :authenticate_user!
  before_action :block_inactive_user!
  respond_to :json
  include ApplicationHelper
  include ScBackendsHelper
  
  include Approval2::ControllerAdditions

  def index
    if params[:advanced_search].present?
      sc_backends = find_sc_backends(params).order("id desc")
    else
      sc_backends = (params[:approval_status].present? and params[:approval_status] == 'U') ? ScBackend.unscoped.where("approval_status =?",'U').order("id desc") : ScBackend.order("id desc")
    end
    @sc_backends_count = sc_backends.count
    @sc_backends = sc_backends.paginate(:per_page => 10, :page => params[:page]) rescue []
  end

  def new
    @sc_backend = ScBackend.new
  end

  def create
    @sc_backend = ScBackend.new(params[:sc_backend])
    if !@sc_backend.valid?
      render "new"
    else
      @sc_backend.created_by = current_user.id
      @sc_backend.save!
      flash[:alert] = "SC Backend successfully #{@sc_backend.approved_id.nil? ? 'created' : 'updated'} and is pending for approval"
      redirect_to @sc_backend
    end
  end

  def show
    @sc_backend = ScBackend.unscoped.find(params[:id])
    @sc_backend_status = @sc_backend.sc_backend_status
    @sc_backend_stat = @sc_backend.sc_backend_stat
    @sc_backend_status_change = @sc_backend.sc_backend_status_changes.new
  end

  def change_status
    @sc_backend = ScBackend.unscoped.find(params[:id])
    @sc_backend_status = @sc_backend.sc_backend_status
    @sc_backend_stat = @sc_backend.sc_backend_stat
    if !@sc_backend_status.nil?
      assign_status(params,current_user)
      ScBackend.transaction do
        if @sc_backend_status_change.save
          @sc_backend_status.last_status_change_id = @sc_backend_status_change.id
          @sc_backend_stat.last_status_change_id = @sc_backend_status_change.id
          if @sc_backend_status.save && @sc_backend_stat.save
            flash[:alert] = "Service center Backend Status changed successfully"
          else
            flash[:alert] = @sc_backend_status.errors.full_messages.join(',') + ',' + @sc_backend_stat.errors.full_messages.join(',')
            raise ActiveRecord::Rollback
          end
        else
          flash[:alert] = @sc_backend_status_change.errors.full_messages.join(',')
          raise ActiveRecord::Rollback
        end
      end
    else
      flash[:alert] = "Service Center Backend Status not changed. Associated SC Backend Status record not found."
    end
    redirect_to @sc_backend
  end

  def previous_status_changes
    @sc_backend = ScBackend.unscoped.find(params[:id])
    previous_status_changes = @sc_backend.sc_backend_status_changes.order("created_at desc")
    @previous_status_changes_count = previous_status_changes.count(:id)
    @previous_status_changes = previous_status_changes.paginate(:per_page => 10, :page => params[:page]) rescue []
  end

  def edit
    sc_backend = ScBackend.unscoped.find(params[:id])
    if sc_backend.approval_status == 'A' && sc_backend.unapproved_record.nil?
      params = (sc_backend.attributes).merge({:approved_id => sc_backend.id, :approved_version => sc_backend.lock_version})
      sc_backend = ScBackend.new(params)
    end
    @sc_backend = sc_backend
  end

  def update
    @sc_backend = ScBackend.unscoped.find_by_id(params[:id])
    @sc_backend.attributes = params[:sc_backend]
    if !@sc_backend.valid?
      render "edit"
    else
      @sc_backend.updated_by = current_user.id
      @sc_backend.save!
      flash[:alert] = 'SC Backend successfully modified and is pending for approval'
      redirect_to @sc_backend
    end
    rescue ActiveRecord::StaleObjectError
      @sc_backend.reload
      flash[:alert] = 'Someone edited the SC Backend the same time you did. Please re-apply your changes to the SC Backend'
      render "edit"
  end 

  def audit_logs
    @sc_backend = ScBackend.unscoped.find(params[:id]) rescue nil
    @audit = @sc_backend.audits[params[:version_id].to_i] rescue nil
  end

  def approve
    redirect_to unapproved_records_path(group_name: 'sc-backend')
  end

  private

  def sc_backend_params
    params.require(:sc_backend).permit(:code, :do_auto_shutdown, :max_consecutive_failures, :window_in_mins, :max_window_failures, 
                                       :do_auto_start, :min_consecutive_success, :min_window_success, :alert_email_to, 
                                       :approval_status, :last_action, :approved_version, :approved_id, :url, :use_proxy,
                                       :created_by, :updated_by, :created_at, :updated_at, :lock_version, :first_requery_after, :requery_interval, :http_username, :http_password,  
                                       sc_backend_status_changes_attributes: [:id, :code, :new_status, :remarks, :created_by, :created_at])
  end
end
