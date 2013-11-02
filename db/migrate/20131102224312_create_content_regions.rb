class CreateContentRegions < ActiveRecord::Migration
  def change
    create_table :content_regions do |t|
      t.belongs_to :content_translation, index: true
      t.belongs_to :definition, index: true
      t.text :content
    end
  end
end
