class ScFaultCodeSearcher
  include ActiveModel::Validations
  attr_accessor :page, :fault_code, :fault_kind
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
      ScFaultCode.none.paginate(per_page: PER_PAGE, page: page)
    end
  end

  private  
  def persisted?
    false
  end

  def find
    reln = ScFaultCode.order("id desc")
    reln = reln.where("fault_code=?", fault_code) if fault_code.present?
    reln = reln.where("fault_kind=?", fault_kind) if fault_kind.present?
    reln
  end
end