# == Schema Information
#
# Table name: pages
#
#  id          :integer          not null, primary key
#  slug        :string(255)
#  author_id   :integer
#  created_at  :datetime
#  updated_at  :datetime
#  path        :string(255)
#  parent_id   :integer
#  lft         :integer
#  rgt         :integer
#  depth       :integer
#  template_id :integer
#

class Page < ActiveRecord::Base
  belongs_to :template, class_name: 'Page::Template'

  translates :title, :content

  acts_as_nested_set

  accepts_nested_attributes_for :translations, allow_destroy: true

  validates :slug, presence: true, uniqueness: { scope: :parent_id }
  validates :path, presence: true, uniqueness: true, if: -> { slug.present? }
  validate :validate_parent_assignability

  after_initialize :set_default_template, if: -> { template.blank? }
  before_validation :sanitize_slug
  before_validation :generate_path, if: -> { slug.present? }
  after_save :update_descendants_paths

  class Translation < Globalize::ActiveRecord::Translation
    validates :title, presence: true
  end

  class << self
    def assignable_as_parent_of(page)
      where.not(id: page.self_and_descendants.pluck(:id))
    end
  end

  def update_path!
    generate_path
    save!
  end

  def template
    super || Page::Template.default
  end

  delegate :template_path, to: :template

  def to_param
    "#{id}-#{title.parameterize}"
  end

  private
  def sanitize_slug
    self.slug = slug.parameterize if slug.present?
  end

  def generate_path
    raise 'slug is blank' if slug.blank?
    if parent.present?
      path_parts = parent.self_and_ancestors.collect(&:slug) << slug
    else
      path_parts = [slug]
    end
    self.path = File.join(*path_parts)
  end

  def set_default_template
    self.template = Page::Template.default
  end

  def update_descendants_paths
    transaction { descendants.each(&:update_path!) }
  end

  def validate_parent_assignability
    errors.add(:parent_id, :invalid) if self_and_descendants.pluck(:id).include?(parent_id)
  end
end
