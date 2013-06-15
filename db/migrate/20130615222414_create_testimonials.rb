class CreateTestimonials < ActiveRecord::Migration
  def change
    create_table :testimonials do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.date :launched_on
      t.string :client_name
      t.string :url

      t.timestamps
    end
  end
end
