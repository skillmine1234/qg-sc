class CreateScProxies < ActiveRecord::Migration
  def change
    create_table :sc_proxies, {:sequence_start_value => '1 cache 20 order increment by 1'} do |t|
      t.string :sc_backend_code, limit: 20, null: false, comment: 'the code assigned to the backend'
      t.string :url, limit: 100, null: false, comment: 'the URL for the proxy'
      t.string :is_enabled, :limit => 1, :null => false, default: 'Y', :comment => "the identifier to specify if the proxy is enabled or not"
      t.string :username, limit: 100, comment: 'the username for the proxy'
      t.string :password, limit: 255, comment: 'the password for the proxy'
      t.datetime :created_at, :null => false, comment: "the timestamp when the record was created"
      t.datetime :updated_at, :null => false, comment: "the timestamp when the record was last updated"
      t.string :created_by, limit: 20, comment: "the person who creates the record"
      t.string :updated_by, limit: 20, comment: "the person who updates the record"
      t.integer :lock_version, :null => false, default: 0, comment: "the version number of the record, every update increments this by 1"
      t.string :last_action, limit: 1, default: 'C', :null => false, comment: "the last action (create, update) that was performed on the record"
      t.string :approval_status, limit: 1, default: 'U', :null => false, comment: "the indicator to denote whether this record is pending approval or is approved"
      t.integer :approved_version, comment: "the version number of the record, at the time it was approved"
      t.integer :approved_id, comment: "the id of the record that is being updated"
      t.index([:sc_backend_code, :approval_status], :unique => true, name: 'sc_proxies_01')
    end
  end
end
