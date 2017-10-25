class ScBackendStatusChange < ActiveRecord::Base
  validates_presence_of :code, :new_status, :remarks

  validates :code, length: { maximum: 20 }
  validates :new_status, length: { minimum: 1, maximum: 1 }

  belongs_to :sc_backend, :foreign_key => 'code', :primary_key => 'code'
  belongs_to :created_user, :foreign_key =>'created_by', :class_name => 'User'

  def full_status
    case new_status
    when 'U'
      'Up'
    when 'D'
      'Down'
    end
  end
end
