class AddRunEveryMinToScJobs < ActiveRecord::Migration
  def change
    add_column :sc_jobs, :run_every_min, :integer, :comment => "the running mins frequency to schedule the report" 
  end
end
