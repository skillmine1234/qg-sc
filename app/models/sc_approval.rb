module ScApproval  
  extend ActiveSupport::Concern
  included do
    has_one :sc_unapproved_record, :as => :sc_approvable

    after_create :on_create_create_sc_unapproved_record
    after_destroy :on_destory_remove_sc_unapproved_records
    after_update :on_update_remove_sc_unapproved_records
  end

  def on_create_create_sc_unapproved_record
    if approval_status == 'U'
      ScUnapprovedRecord.create!(:sc_approvable => self)
    end
  end

  def on_destory_remove_sc_unapproved_records
    if approval_status == 'U'
      sc_unapproved_record.delete
    end
  end
  
  def on_update_remove_sc_unapproved_records
    if approval_status == 'A' and approval_status_was == 'U'
      sc_unapproved_record.delete
    end
  end 
  
end