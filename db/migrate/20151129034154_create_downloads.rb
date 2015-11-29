class CreateDownloads < ActiveRecord::Migration
  def change
    create_table :downloads do |t|
      t.belongs_to :downloadable, index: true, polymorphic: true, null: false
      t.datetime :created_at, null: false
    end
  end
end
