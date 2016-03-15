class SetEmptyHitTypesToDownload < ActiveRecord::Migration
  def up
    update "UPDATE hits SET type = 'Download' WHERE type IS NULL"
  end
end
