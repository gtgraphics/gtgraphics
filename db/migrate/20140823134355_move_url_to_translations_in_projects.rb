class MoveUrlToTranslationsInProjects < ActiveRecord::Migration
  def up
    add_column :project_translations, :url, :string

    locale = quote(I18n.default_locale.to_s)
    select_all("SELECT id, url FROM projects").each do |project|
      project_id = project['id']
      url = quote(project['url'])
      update <<-SQL
        UPDATE project_translations
        SET url = #{url}
        WHERE project_id = #{project_id}
        AND locale = #{locale}
      SQL
    end

    remove_column :projects, :url
  end

  def down
    add_column :projects, :url, :string

    locale = quote(I18n.default_locale.to_s)
    sql = "SELECT project_id, url FROM project_translations WHERE locale = #{locale}"
    select_all(sql).each do |project_translation|
      project_id = project_translation['project_id']
      url = quote(project_translation['url'])
      update <<-SQL
        UPDATE projects
        SET url = #{url}
        WHERE id = #{project_id}
      SQL
    end

    remove_column :project_translations, :url
  end
end
