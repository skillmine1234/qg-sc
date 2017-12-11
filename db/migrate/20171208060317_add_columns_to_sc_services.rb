class AddColumnsToScServices < ActiveRecord::Migration
  def change
    add_column :sc_services, :created_at, :datetime, comment: "the timestamp when the record was created"
    add_column :sc_services, :updated_at, :datetime, comment: "the timestamp when the record was last updated"
    add_column :sc_services, :created_by, :string, limit: 20, comment: "the person who creates the record"
    add_column :sc_services, :updated_by, :string, limit: 20, comment: "the person who updates the record"
    add_column :sc_services, :lock_version, :integer, :null => false, default: 0, comment: "the version number of the record, every update increments this by 1"
    add_column :sc_services, :last_action, :string, limit: 1, default: 'C', :null => false, comment: "the last action (create, update) that was performed on the record"
    add_column :sc_services, :approval_status, :string, limit: 1, default: 'U', :null => false, comment: "the indicator to denote whether this record is pending approval or is approved"
    add_column :sc_services, :approved_version, :integer, comment: "the version number of the record, at the time it was approved"
    add_column :sc_services, :approved_id, :integer, comment: "the id of the record that is being updated"

    ScService.unscoped.update_all(created_at: Time.zone.now, updated_at: Time.zone.now, approval_status: 'A')
    change_column :sc_services, :created_at, :datetime, null: false
    change_column :sc_services, :updated_at, :datetime, null: false

    remove_index :sc_services, [:code]
    add_index :sc_services, [:code, :approval_status], name: 'sc_services_01'
    remove_index :sc_services, [:name]
    add_index :sc_services, [:name, :approval_status], name: 'sc_services_02'
    
    add_column :sc_services, :url, :string, limit: 100, comment: 'the url for the service'
    add_column :sc_services, :use_proxy, :string, limit: 1, :null => false, :default => 'Y', comment: 'the indicator whether the service will use proxy or not'
    add_column :sc_services, :http_username, :string, limit: 100, comment: 'the username for the service'
    add_column :sc_services, :http_password, :string, limit: 255, comment: 'the password for the service'
  end
end
