class Editor::Link
  include ActiveModel::Model

  attr_accessor :url, :new_window
  alias_method :new_window?, :new_window
  
  validates :url, presence: true, url: true
end