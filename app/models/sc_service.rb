class ScService < ActiveRecord::Base
  validates_presence_of :code, :name
  validates_uniqueness_of :code,:name

  has_many :incoming_file_types
  has_many :outgoing_file_types

  def has_auto_upload?
    auto_uploads = incoming_file_types.where("auto_upload=?",'N')
    auto_uploads.empty? ? true : false
  end
end
