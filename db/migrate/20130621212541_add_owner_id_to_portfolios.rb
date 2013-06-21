class AddOwnerIdToPortfolios < ActiveRecord::Migration
  def change
    add_column :portfolios, :owner_id, :integer
  end
end
