class AddUserAgentToShouts < ActiveRecord::Migration
  def change
    add_column :shouts, :user_agent, :string
  end
end
