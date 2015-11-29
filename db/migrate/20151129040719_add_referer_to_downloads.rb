class AddRefererToDownloads < ActiveRecord::Migration
  def change
    add_column :downloads, :referer, :string
  end
end
