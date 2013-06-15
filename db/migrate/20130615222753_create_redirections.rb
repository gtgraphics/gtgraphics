class CreateRedirections < ActiveRecord::Migration
  def change
    create_table :redirections do |t|
      t.string :source_url
      t.string :destination_url

      t.timestamps
    end
  end
end
