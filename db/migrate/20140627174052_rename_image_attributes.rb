class RenameImageAttributes < ActiveRecord::Migration
  def change
    %w(images image_styles).each do |table_name|
      rename_column table_name, :asset_file_name, :asset
      rename_column table_name, :asset_content_type, :content_type
      rename_column table_name, :asset_file_size, :file_size
    end
  end
end
