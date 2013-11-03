class RenameContentToBodyInContentTranslations < ActiveRecord::Migration
  def change
    rename_column :content_translations, :content, :body
    rename_column :regions, :content, :body
  end
end
