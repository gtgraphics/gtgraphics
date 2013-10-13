class CreatePageTemplates < ActiveRecord::Migration
  def change
    create_table :page_templates do |t|
      t.string :file_name, null: false, index: { unique: true }
      t.string :name
      t.text :description
      t.attachment :screenshot
      t.boolean :default, null: false, default: false
      t.boolean :active, null: false, default: true
    end

    reversible do |dir|
      dir.up do
        remove_column :pages, :template
        add_reference :pages, :template
      end
      dir.down do
        remove_reference :pages, :template
        add_column :pages, :template, :string
      end
    end
  end
end
