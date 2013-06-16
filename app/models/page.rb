class Page < ActiveRecord::Base
  acts_as_tree

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :path, presence: true
  validate :check_path_uniqueness

  before_validation :set_slug
  before_validation :set_path
  before_validation :sanitize_path
  after_save :update_child_paths

  def parents
    ancestors.reverse
  end

  def to_s
    title
  end

  private
  def check_path_uniqueness
    errors.add(:path, :taken) if path.present? and Redirection.exists?(source_path: path)
  end

  def sanitize_path
    self.path = path.strip.gsub(/\A\/+|\/+\z/, '')
  end

  def set_slug
    self.slug = title.parameterize if slug.blank? and title.present?
  end

  def set_path
    self.path = File.join(*parents.collect(&:slug), self.slug)
  end

  def update_child_paths
    # TODO collect children and children-children ...
    
  end
end
