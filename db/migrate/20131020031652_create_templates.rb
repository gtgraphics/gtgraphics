class CreateTemplates < ActiveRecord::Migration
  def up
    create_table :templates do |t|
      t.string :file_name
      t.string :type
      t.boolean :default, default: false, null: false
      t.timestamps
    end
    
    create_table :template_translations do |t|
      t.references :template
      t.string :locale, limit: 2
      t.string :name
      t.text :description
    end
  end

  def down
    drop_table :templates
    drop_table :template_translations
  end
end
