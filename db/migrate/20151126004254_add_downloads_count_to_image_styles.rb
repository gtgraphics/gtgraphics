class AddDownloadsCountToImageStyles < ActiveRecord::Migration
  def change
    add_column :image_styles, :downloads_count, :integer, default: 0, null: false
  end
end
