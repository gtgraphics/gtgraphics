class CreateImageDownloads < ActiveRecord::Migration
  def change
    create_table :image_downloads do |t|
      t.belongs_to :image, index: true, foreign_key: true
      t.belongs_to :attachment, index: true, foreign_key: true
      t.integer :position, null: false
    end
  end
end
