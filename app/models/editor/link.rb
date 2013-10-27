class Editor::Link
  include ActiveModel::Model
  include Virtus.model

  attribute :page_id, Integer
  attribute :url, String
  attribute :new_window, Boolean

  validates :url, presence: true, url: true
end