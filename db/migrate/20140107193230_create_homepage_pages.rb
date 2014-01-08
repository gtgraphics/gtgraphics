class CreateHomepagePages < ActiveRecord::Migration
  def change
    create_table :homepage_pages do |t|
      t.belongs_to :template, index: true
    end
  end
end
