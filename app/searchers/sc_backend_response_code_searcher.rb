class ScBackendResponseCodeSearcher
  include ActiveModel::Validations
  attr_accessor :page, :sc_backend_code, :response_code, :approval_status
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
      ScBackendResponseCode.none.paginate(per_page: PER_PAGE, page: page)
    end
  end

  private  
  def persisted?
    false
  end

  def find
    reln = approval_status == 'U' ? ScBackendResponseCode.unscoped.where("approval_status =?",'U').order("id desc") : ScBackendResponseCode.order("id desc")
    reln = reln.where("sc_backend_code=?", sc_backend_code) if sc_backend_code.present?
    reln = reln.where("response_code=?", response_code) if response_code.present?
    reln
  end
end