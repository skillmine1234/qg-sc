class AddColumnCldrToScJobs < ActiveRecord::Migration
  def change
    add_column :sc_jobs, :cldr, :string, null: false, default: 'GREG', comment: 'the calendar which needs to be followed to run the job'   
    add_column :sc_jobs, :status_code, :string, :limit => 50, comment: 'the status of the job'   
    add_column :sc_jobs, :fault_code, :string, :limit => 50, comment: "the code that identifies the business failure reason/exception"
    add_column :sc_jobs, :fault_subcode, :string, :limit => 50, comment: "the error code that the third party will return"  
    add_column :sc_jobs, :fault_reason, :string, :limit => 1000, comment: "the english reason of the business failure reason/exception"  
    add_column :sc_jobs, :fault_bitstream, :text, comment: "the fault bitstream"                    
  end
end
