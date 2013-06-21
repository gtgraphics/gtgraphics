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
  include Sluggable

  acts_as_nested_set
  acts_as_sluggable_on :title

  validates :title, presence: true
  validates :path, presence: true
  validate :check_path_uniqueness
  with_options on: :update do |page|
    page.validate :check_parent_is_not_self
    page.validate :check_ancestor_is_not_descendant
  end

  before_validation :set_path
  before_validation :sanitize_path
  after_save :update_descendant_paths

  default_scope -> { order(:lft) }

  class << self
    def generate_path(page)
      page.root? ? page.slug : PathHelper.join_path(page.parent.self_and_ancestors.pluck(:slug), page.slug) if page.slug.present?
    end

    def without_self_and_descendants_of(other_page)
      without(other_page).without_descendants_of(other_page)
    end

    def without(other_page)
      if other_page.persisted?
        where('id != ?', other_page.id)
      else
        all
      end
    end

    def without_descendants_of(other_page)
      if other_page.persisted?
        descendant_ids = other_page.descendants.pluck(:id)
        if descendant_ids.empty?
          all
        else
          where('id NOT IN (?)', descendant_ids)
        end
      else
        all
      end
    end
  end

  def to_param
    path
  end

  def to_s
    title
  end

  private
  def check_parent_is_not_self
    errors.add(:parent_id, 'cannot be self') if parent_id.present? and parent_id == id
  end

  def check_ancestor_is_not_descendant
    errors.add(:parent_id, 'cannot be a child of itself') if parent_id.present? and descendants.exists?(id: parent.self_and_ancestors.pluck(:id))
  end

  def check_path_uniqueness
    errors.add(:path, :taken) if path.present? and Redirection.exists?(source_path: path)
  end

  def sanitize_path
    PathHelper.sanitize_path!(path)
  end

  def set_path
    self.path = self.class.generate_path(self)
  end

  def update_descendant_paths
    descendants.each do |descendant|
      descendant.update(path: File.join(path, descendant.slug))
    end
  end
end
