class SetNotNullConstraintsOnTags < ActiveRecord::Migration
  def up
    change_column :tags, :label, :string, null: false
    change_column :tags, :slug, :string, null: false
  end

  def down
    change_column :tags, :label, :string, null: true
    change_column :tags, :slug, :string, null: true
  end
end
