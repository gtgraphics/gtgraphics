class CreateContentPages < ActiveRecord::Migration
  def change
    create_table :content_pages do |t|
      t.belongs_to :template, index: true
    end
  end
end
