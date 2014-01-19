class AddDescendantsCountToPages < ActiveRecord::Migration
  def up
    add_column :pages, :descendants_count, :integer, default: 0

    Page.reset_column_information
    Page.all.each do |page|
      page.save!
    end
  end

  def down
    remove_column :pages, :descendants_count
  end
end
