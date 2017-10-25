class ScBackendSettingSearcher
  include ActiveModel::Validations
  attr_accessor :page, :backend_code, :service_code, :app_id, :approval_status
  PER_PAGE = 10
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
  
  def paginate
    if valid? 
      find.paginate(per_page: PER_PAGE, page: page)
    else
      ScBackendSetting.none.paginate(per_page: PER_PAGE, page: page)
    end
  end

  private  
  def persisted?
    false
  end

  def find
    reln = approval_status == 'U' ? ScBackendSetting.unscoped.where("approval_status =?",'U').order("id desc") : ScBackendSetting.order("id desc")
    reln = reln.where("backend_code=?", backend_code) if backend_code.present?
    reln = reln.where("service_code=?", service_code) if service_code.present?
    reln = reln.where("app_id=?", app_id) if app_id.present?
    reln
  end
end