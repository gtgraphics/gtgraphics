class IncreaseIpColumnSizeOnHits < ActiveRecord::Migration
  def change
    change_column :hits, :ip, :string, limit: 15
  end
end
