class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :label
    end
    add_index :tags, :label, unique: true
  end
end
