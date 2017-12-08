class AddColumnsToHttpUsernameAndHttpPasswordToScBackends < ActiveRecord::Migration
  def change
    add_column :sc_backends, :http_username, :string, limit: 100, comment: 'the username for the backend'
    add_column :sc_backends, :http_password, :string, limit: 255, comment: 'the password for the backend'
  end
end
