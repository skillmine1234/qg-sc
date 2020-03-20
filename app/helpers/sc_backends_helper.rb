module ScBackendsHelper
  def find_sc_backends(params)
    sc_backends = (params[:approval_status].present? and params[:approval_status] == 'U') ? ScBackend.unscoped : ScBackend
    sc_backends = sc_backends.where("code IN (?)",params[:code].split(",").collect(&:strip)) if params[:code].present?
    sc_backends
  end

  def assign_status(params,current_user)
    @sc_backend_status_change = @sc_backend.sc_backend_status_changes.build
    if @sc_backend_status.status == 'U'
      @sc_backend_status.status = 'D'
      @sc_backend_status_change.new_status = 'D'
    elsif @sc_backend_status.status == 'D'
      @sc_backend_status.status = 'U'
      @sc_backend_status_change.new_status = 'U'
      @sc_backend_stat.assign_attributes(window_success_cnt: 0, consecutive_failure_cnt: 0,
                                         window_failure_cnt: 0)
    end
    @sc_backend_status_change.remarks = params[:sc_backend_status_change][:remarks]
    @sc_backend_status_change.created_by = current_user.id
  end
end
