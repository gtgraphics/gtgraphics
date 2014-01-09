class CreateContactFormPages < ActiveRecord::Migration
  def change
    create_table :contact_form_pages do |t|
      t.belongs_to :template, index: true
    end
  end
end
