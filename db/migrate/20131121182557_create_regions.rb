class CreateRegions < ActiveRecord::Migration
  def change
    create_table :regions do |t|
      t.references :definition, index: true
      t.references :page, index: true
      t.text :body
      t.timestamps
    end
  end
end
