class AddPathEmbeddableTypeAndPublishedIndexToPages < ActiveRecord::Migration
  def change
    add_index :pages, [:path, :embeddable_type, :published]
    add_index :pages, [:path, :published]
  end
end
