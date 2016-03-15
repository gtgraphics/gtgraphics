class RenamePageHitsCountIntoVisitsCount < ActiveRecord::Migration
  def up
    rename_column :pages, :hits_count, :visits_count
  end

  def down
    rename_column :pages, :visits_count, :hits_count
  end
end
