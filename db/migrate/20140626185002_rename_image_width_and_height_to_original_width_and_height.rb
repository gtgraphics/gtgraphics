class RenameImageWidthAndHeightToOriginalWidthAndHeight < ActiveRecord::Migration
  def change
    %w(images image_styles).each do |table_name|
      %w(width height).each do |column_name|
        rename_column table_name, column_name, "original_#{column_name}"
        rename_column table_name, "transformed_#{column_name}", column_name
      end
    end
  end
end
