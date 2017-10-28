class AddColumnsToScBackends < ActiveRecord::Migration
  def change
    add_column :sc_backends, :url, :string, :limit => 100, comment: 'the request url for the backend'
    add_column :sc_backends, :use_proxy, :string, limit: 1, :null => false, :default => 'Y', comment: 'the identifier to tell if proxy has to be used'
  end
end
