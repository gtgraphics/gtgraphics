class CreateTaggings < ActiveRecord::Migration
  def change
    create_table :taggings do |t|
      t.references :tag, index: true, null: false
      t.references :taggable, polymorphic: true, index: true, null: false
    end
  end
end
