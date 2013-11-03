class CreateRegions < ActiveRecord::Migration
  def change
    create_table :regions do |t|
      t.belongs_to :regionable, polymorphic: true, index: true
      t.belongs_to :definition, index: true
      t.text :content
      t.timestamps
    end
  end
end
