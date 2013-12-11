class AddStateToPages < ActiveRecord::Migration
  def up
    add_column :pages, :state, :string
    add_index :pages, :state
 
    Page.reset_column_information
    Page.where(published: true).update_all(state: 'published')
    Page.where(published: false).update_all(state: 'hidden')
 
    change_column :pages, :state, :string, null: false
    remove_column :pages, :published
  end
 
  def down
    add_column :pages, :published
 
    Page.reset_column_information
    Page.where(state: 'published').update_all(published: true)
    Page.where(state: %w(hidden drafted)).update_all(published: false)
 
    remove_column :pages, :state
  end
end