class AddUniqueIndexesToTranslations < ActiveRecord::Migration
  def change
    %w(attachments images pages project_pages region_contents snippets templates).each do |table_name|
      translation_table_name = "#{table_name.singularize}_translations"
      foreign_key = "#{table_name.singularize}_id".to_sym
      index_name = "index_#{translation_table_name}_on_foreign_id_and_locale"
      add_index translation_table_name, [foreign_key, :locale], unique: true, name: index_name
    end
  end
end
