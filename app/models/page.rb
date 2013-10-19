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
  include BatchTranslatable

  RESERVED_SLUGS = %w(
    images
    albums
    galleries
  )

  belongs_to :template, class_name: 'Page::Template'

  translates :title, :content, fallbacks_for_empty_translations: true

  acts_as_nested_set

  accepts_nested_attributes_for :translations, allow_destroy: true

  validates :slug, presence: true, uniqueness: { scope: :parent_id }, exclusion: { in: RESERVED_SLUGS, if: :root? }
  validates :path, presence: true, uniqueness: true, if: -> { slug.present? }
  validate :validate_parent_assignability

  after_initialize :set_default_template, if: -> { template.blank? }
  before_validation :generate_slug
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

  def content_html
    template = Liquid::Template.parse(content)
    template.render(to_liquid).html_safe
  end

  def to_liquid
    attributes.slice(*%w(title slug path)).merge('children' => children)
  end

  private
  def generate_slug
    self.slug = title(I18n.default_locale) if slug.blank? and title.present?
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
