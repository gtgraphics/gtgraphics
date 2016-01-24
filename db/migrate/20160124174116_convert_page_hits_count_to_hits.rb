class ConvertPageHitsCountToHits < ActiveRecord::Migration
  def up
    rename_column :pages, :hits_count, :visits_count

    pages = select_all('SELECT id, visits_count FROM pages')
    pages.each do |page|
      visits_count = page['visits_count'].to_i
      time = quote(1.month.ago)
      visits_count.times do
        insert <<-SQL.strip_heredoc
          INSERT INTO hits (hittable_id, hittable_type, created_at)
          VALUES (#{page['id']}, 'Page', #{time})
        SQL
      end
    end
  end

  def down
    rename_column :pages, :visits_count, :hits_count
  end
end
