class AddNameAndPathToPortfolios < ActiveRecord::Migration
  def up
    remove_column :portfolios, :owner_name
    add_column :portfolios, :name, :string
    add_column :portfolios, :path, :string
    add_index :portfolios, :path, unique: true
  end

  def down
    add_column :portfolios, :owner_name, :string
    drop_column :portfolios, :name
    drop_column :portfolios, :path
    drop_index :portfolios, :path
  end
end
