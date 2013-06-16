class CreateRedirections < ActiveRecord::Migration
  def change
    create_table :redirections do |t|
      t.string :source_path
      t.string :destination_url
      t.timestamps
    end
    add_index :redirections, :source_path, unique: true
  end
end