class AddPermanentToRedirections < ActiveRecord::Migration
  def change
    add_column :redirections, :permanent, :boolean, null: false, default: false
  end
end
