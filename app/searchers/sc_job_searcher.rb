class ScJobSearcher
  include ActiveModel::Validations
  attr_accessor :page, :code, :status_code
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
      ScJob.none.paginate(per_page: PER_PAGE, page: page)
    end
  end

  private  
  def persisted?
    false
  end

  def find
    reln = ScJob.order("id desc")
    reln = reln.where("code IN (?)", code.split(",").collect(&:strip)) if code.present?
    reln = reln.where("status_code IN (?)", status_code.split(",").collect(&:strip)) if status_code.present?
    reln
  end
end