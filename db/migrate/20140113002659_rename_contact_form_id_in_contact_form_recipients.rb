class RenameContactFormIdInContactFormRecipients < ActiveRecord::Migration
  def change
    rename_column :contact_form_recipients, :contact_form_id, :contact_form_page_id
  end
end
