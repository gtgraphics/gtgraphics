class CreateRedirectionPages < ActiveRecord::Migration
  def change
    create_table :redirection_pages do |t|
      t.boolean :external, null: false, default: false
      t.belongs_to :destination_page, index: true
      t.string :destination_url
      t.boolean :permanent, null: false, default: false
    end
  end
end
