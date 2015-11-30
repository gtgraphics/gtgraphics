class MigrateExistingDownloads < ActiveRecord::Migration
  def up
    migrate_downloadable('image_styles', 'Image::Style')
    migrate_downloadable('attachments', 'Attachment')
  end

  def down
    say 'Nothing to do here'
  end

  private

  def migrate_downloadable(table_name, model_name)
    created_at = quote((Time.zone.now - 1.month).end_of_month.to_s(:db))

    records = select_all("SELECT id, downloads_count FROM #{table_name}")
    records.each do |record|
      record_id = record['id']
      downloads_count = record['downloads_count'].to_i

      existing_entries_count = select_one(<<-SQL)['count'].to_i
        SELECT COUNT(*)
        FROM downloads
        WHERE downloadable_type = #{quote(model_name)}
        AND downloadable_id = #{record_id}
      SQL

      missing_entries_count = downloads_count - existing_entries_count
      missing_entries_count.times do
        insert <<-SQL
          INSERT INTO downloads
          (downloadable_type, downloadable_id, created_at)
          VALUES (#{quote(model_name)}, #{record_id}, #{created_at})
        SQL
      end
    end
  end
end
