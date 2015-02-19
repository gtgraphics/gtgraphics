module Publishable
  extend ActiveSupport::Concern

  included do
    scope :hidden, -> { where(published: false) }
    scope :published, -> { where(published: true) }
  end

  def hide
    self.published = false
  end

  def hide!
    update_column(:published, false)
  end

  def hidden?
    !published?
  end

  def publish
    self.published = true
  end

  def publish!
    update_column(:published, true)
  end
end
