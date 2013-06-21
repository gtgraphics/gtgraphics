class CreatePortfolios < ActiveRecord::Migration
  def change
    create_table :portfolios do |t|
      t.string :owner_name
      t.string :slug
      t.text :description
      t.timestamps
    end
    add_index :portfolios, :slug, unique: true
  end
end
