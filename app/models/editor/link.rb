class Editor::Link
  include ActiveModel::Model
  include Virtus.model

  attr_accessor :target

  attribute :caption, String
  attribute :external, Boolean, default: false
  attribute :page_id, Integer
  attribute :url, String
  attribute :new_window, Boolean

  validates :target, presence: true
  validates :url, presence: true, url: true, if: :external?
  validates :page_id, presence: true, if: :internal?

  def internal?
    !external?
  end
end