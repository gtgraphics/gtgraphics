class DropRegionTranslations < ActiveRecord::Migration
  def up
    drop_table :region_translations rescue nil
  end

  def down
  end
end
