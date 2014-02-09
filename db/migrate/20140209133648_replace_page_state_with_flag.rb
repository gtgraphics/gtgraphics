class ReplacePageStateWithFlag < ActiveRecord::Migration
  def up
    add_column :pages, :published, :boolean, default: true, null: false

    update "UPDATE pages SET published = 't' WHERE state = 'published'"
    update "UPDATE pages SET published = 'f' WHERE state != 'published'"

    remove_column :pages, :state
  end

  def down
    add_column :pages, :state, :string, default: 'published', null: false

    update "UPDATE pages SET published = 't' WHERE state = 'published'"
    update "UPDATE pages SET published = 'f' WHERE state != 'published'"

    remove_column :pages, :published
  end
end
