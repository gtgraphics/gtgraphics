class CreateProjectPages < ActiveRecord::Migration
  def change
    create_table :project_pages do |t|
      t.belongs_to :template, index: true
      t.string :client_name
      t.string :client_url
      t.date :released_on
    end

    create_table :project_page_translations do |t|
      t.belongs_to :project_page, index: true
      t.string :locale, limit: 2
      t.string :name
      t.text :description
    end
  end
end