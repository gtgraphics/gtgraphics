class AddEmbeddableToPages < ActiveRecord::Migration
  def change
    add_reference :pages, :embeddable, polymorphic: true, index: true
    add_index :pages, [:path, :embeddable_type]
  end
end
