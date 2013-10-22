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
#  published       :boolean
#  embeddable_id   :integer
#  embeddable_type :string(255)
#  template_id     :integer
#

class Page < ActiveRecord::Base
  EMBEDDABLE_TYPES = %w(
    Content
    Gallery
    Image
  ).freeze

  RESERVED_SLUGS = %w(
    images
    albums
    galleries
  ).freeze

  acts_as_nested_set

  belongs_to :embeddable, polymorphic: true
  belongs_to :template

  delegate :title, to: :embeddable, allow_nil: true

  validates :embeddable_id, presence: true, unless: -> { embeddable_class and embeddable_class.bound_to_page? }
  validates :embeddable_type, presence: true, inclusion: { in: EMBEDDABLE_TYPES }
  validates :slug, presence: true, uniqueness: { scope: :parent_id }, exclusion: { in: RESERVED_SLUGS, if: :root? }
  validates :path, presence: true, uniqueness: true, if: -> { slug.present? }
  validate :validate_parent_assignability
  validate :validate_template_type, if: -> { embeddable_type.present? }

  accepts_nested_attributes_for :embeddable

  before_validation :generate_slug
  before_validation :generate_path, if: -> { slug.present? }
  after_save :update_descendants_paths
  after_destroy :destroy_embeddable

  default_scope -> { order(:lft) }
  scope :published, -> { where(published: true) }
  scope :hidden, -> { where(published: false) }

  EMBEDDABLE_TYPES.each do |embeddable_type|
    scope embeddable_type.underscore.pluralize, -> { where(embeddable_type: embeddable_type) }

    class_eval %{
      def #{embeddable_type}?
        self.embeddable_type == '#{embeddable_type}'
      end
    }
  end

  class MissingTemplate < Exception
    attr_reader :page

    def initialize(page)
      @page = page
      super "Missing template for #{@page.embeddable_type} in #{@page.inspect}"
    end
  end

  class << self
    def assignable_as_parent_of(page)
      where.not(id: page.self_and_descendants.pluck(:id))
    end

    def embedding(type)
      where(embeddable_type: type.to_s.classify)
    end

    def embeddable_types
      EMBEDDABLE_TYPES
    end

    def template_types
      @@template_types ||= template_types_hash.values.freeze
    end

    def template_types_hash
      @@template_types_hash ||= Hash[*EMBEDDABLE_TYPES.map do |embeddable_type|
        [embeddable_type, "Template::#{embeddable_type}"]
      end.flatten].freeze
    end
  end

  def children_with_embedded(type)
    children.embedding(type).includes(:embeddable)
  end

  def embeddable
    super || embeddable_class.try(:new)
  end

  def embeddable_class
    @embeddable_class ||= (embeddable_type.in?(self.class.embeddable_types) ? embeddable_type.constantize : nil)
  end

  def hidden?
    !published?
  end

  def template
    super || template_class.default
  end

  def template_class
    @template_class ||= self.class.template_types_hash[embeddable_type].try(:constantize)
  end

  def template_path
    template.try(:view_path) || raise(Page::MissingTemplate.new(self))
  end

  def to_s
    title
  end

  def update_path!
    generate_path
    save!
  end

  private
  def destroy_embeddable
    embeddable.destroy if embeddable and embeddable.class.bound_to_page?
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
    self.template = template_class.default
  end

  def update_descendants_paths
    transaction { descendants.each(&:update_path!) }
  end

  def validate_parent_assignability
    errors.add(:parent_id, :invalid) if self_and_descendants.pluck(:id).include?(parent_id)
  end

  def validate_template_type
    errors.add(:template_id, :invalid) if self.class.template_types_hash[embeddable_type].nil?
  end
end
