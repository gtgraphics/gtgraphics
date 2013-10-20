# == Schema Information
#
# Table name: pages
#
#  id              :integer          not null, primary key
#  slug            :string(255)
#  author_id       :integer
#  created_at      :datetime
#  updated_at      :datetime
#  path            :string(255)
#  parent_id       :integer
#  lft             :integer
#  rgt             :integer
#  depth           :integer
#  template_id     :integer
#  published       :boolean
#  embeddable_id   :integer
#  embeddable_type :string(255)
#

class Page < ActiveRecord::Base
  EMBEDDABLE_TYPES = %w(
    Content
    Album
    Image
  ).freeze

  RESERVED_SLUGS = %w(
    images
    albums
    galleries
  ).freeze

  acts_as_nested_set

  belongs_to :embeddable, polymorphic: true

  validates :embeddable_type, presence: true, inclusion: { in: EMBEDDABLE_TYPES }
  validates :slug, presence: true, uniqueness: { scope: :parent_id }, exclusion: { in: RESERVED_SLUGS, if: :root? }
  validates :path, presence: true, uniqueness: true, if: -> { slug.present? }
  validate :validate_template_type, if: -> { template.present? and embeddable_type.present? }
  validate :validate_parent_assignability

  after_initialize :set_default_template, if: -> { template.blank? }
  before_validation :generate_slug
  before_validation :generate_path, if: -> { slug.present? }
  after_save :update_descendants_paths
  after_destroy :destroy_embeddable

  scope :published, -> { where(published: true) }
  scope :hidden, -> { where(published: false) }

  EMBEDDABLE_TYPES.each do |embeddable_type|
    scope embeddable_type.pluralize, -> { where(embeddable_type: embeddable_type) }

    class_eval %{
      def #{embeddable_type}?
        self.embeddable_type == '#{embeddable_type}'
      end
    }
  end

  class << self
    def assignable_as_parent_of(page)
      where.not(id: page.self_and_descendants.pluck(:id))
    end

    def embeddable_types
      EMBEDDABLE_TYPES
    end
  end

  def hidden?
    !published?
  end

  def update_path!
    generate_path
    save!
  end

  private
  def destroy_embeddable
    embeddable.destroy if content?
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

  def generate_slug
    self.slug = title(I18n.default_locale) if slug.blank? and title.present?
    self.slug = slug.parameterize if slug.present?
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

  def validate_template_type
    errors.add(:template_id, :invalid) unless template.class.name == "Template::#{embeddable_type}"
  end
end
