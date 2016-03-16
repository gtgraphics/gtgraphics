class IncreaseIpColumnSizeOnHits < ActiveRecord::Migration
  def up
    change_column :hits, :ip, :string, limit: 15
  end
end
