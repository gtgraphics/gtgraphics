class AddTimestampsToProjectImages < ActiveRecord::Migration
  def change
    change_table :project_images do |t|
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        date = quote(Time.now.to_s(:db))
        update("UPDATE project_images SET created_at = #{date}, updated_at = #{date}")
      end
    end
  end
end
