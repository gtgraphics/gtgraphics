class AddIpToHits < ActiveRecord::Migration
  def change
    add_column :hits, :ip, :string, limit: 11
  end
end
