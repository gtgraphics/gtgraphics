class AddRefererAndUserAgentToDownloads < ActiveRecord::Migration
  def change
    add_column :downloads, :referer, :string
    add_column :downloads, :user_agent, :string
  end
end
