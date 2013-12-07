class CreateContactFormRecipientsJoinTable < ActiveRecord::Migration
  def change
    create_table :contact_form_recipients, id: false do |t|
      t.belongs_to :contact_form
      t.belongs_to :recipient
      t.index [:contact_form_id, :recipient_id], name: 'index_cfr_on_contact_form_id_and_recipient_id'
      t.index [:recipient_id, :contact_form_id], name: 'index_cfr_on_recipient_id_and_contact_form_id'
    end
  end
end
