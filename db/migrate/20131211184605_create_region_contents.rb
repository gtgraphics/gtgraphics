class CreateRegionContents < ActiveRecord::Migration
  def change
    create_table :region_contents do |t|
    end

    reversible do |dir|
      dir.up { Region::Content.create_translation_table! body: :text }
      dir.down { Region::Content.drop_translation_table! }
    end
  end
end
