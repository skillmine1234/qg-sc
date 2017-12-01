class AddNewColumnsToScBackends < ActiveRecord::Migration
  def change
    add_column :sc_backends, :first_requery_after, :integer, null: false, default: 15, comment: 'the interval (in mins) after which the first requery is attempted'
    add_column :sc_backends, :requery_interval, :integer, null: false, default: 15, comment: 'the interval (in mins) between subsequent requery attempts'
  end
end
