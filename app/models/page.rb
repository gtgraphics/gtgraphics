# == Schema Information
#
# Table name: pages
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  slug       :string(255)
#  content    :text
#  created_at :datetime
#  updated_at :datetime
#  path       :string(255)
#  parent_id  :integer
#  lft        :integer
#  rgt        :integer
#  depth      :integer
#

class Page < ActiveRecord::Base
  acts_as_nested_set

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :path, presence: true
  validate :check_path_uniqueness
  validate :check_ancestor_is_not_descendant

  before_validation :set_slug
  before_validation :set_path
  before_validation :sanitize_path
  after_save :update_descendant_paths

  def to_s
    title
  end

  private
  def check_ancestor_is_not_descendant
    errors.add(:parent_id, :invalid) if parent_id.present? and descendants.exists?(id: parent.self_and_ancestors.pluck(:id))
  end

  def check_path_uniqueness
    errors.add(:path, :taken) if path.present? and Redirection.exists?(source_path: path)
  end

  def sanitize_path
    self.path = path.strip.gsub(/\A\/+|\/+\z/, '') # strip leading and ending slashes
  end

  def set_slug
    self.slug = title.parameterize if slug.blank? and title.present?
  end

  def set_path
    self.path = root? ? slug : File.join(*parent.self_and_ancestors.pluck(:slug), slug) if slug.present?
  end

  def update_descendant_paths
    descendants.each do |descendant|
      descendant.update(path: File.join(path, descendant.slug))
    end
  end
end
