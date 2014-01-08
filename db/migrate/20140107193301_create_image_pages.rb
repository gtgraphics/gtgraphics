class CreateImagePages < ActiveRecord::Migration
  def change
    create_table :image_pages do |t|
      t.belongs_to :template, index: true
      t.belongs_to :image, index: true
    end
  end
end
