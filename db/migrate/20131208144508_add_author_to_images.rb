class AddAuthorToImages < ActiveRecord::Migration
  def change
    add_reference :images, :author, index: true
  end
end
