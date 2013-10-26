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
#  published       :boolean          default(TRUE), not null
#  embeddable_id   :integer
#  embeddable_type :string(255)
#

class Page < ActiveRecord::Base
  EMBEDDABLE_TYPES = %w(
    Content
    Gallery
    Image
    Redirection
  ).freeze

  RESERVED_SLUGS = %w(
    images
    albums
    galleries
  ).freeze

  acts_as_nested_set

  belongs_to :embeddable, polymorphic: true, autosave: true
  belongs_to :template

  delegate :title, to: :embeddable, allow_nil: true

  validates :embeddable, presence: true
  validates :embeddable_id, presence: true, unless: -> { embeddable_class and embeddable_class.bound_to_page? }
  validates :embeddable_type, presence: true, inclusion: { in: EMBEDDABLE_TYPES }
  validates :slug, presence: true, uniqueness: { scope: :parent_id }, exclusion: { in: RESERVED_SLUGS, if: :root? }
  validates :path, presence: true, uniqueness: true, if: -> { slug.present? }
  validate :validate_parent_assignability
  validate :validate_template_type

  before_validation :generate_slug
  before_validation :generate_path, if: -> { slug.present? }
  after_save :update_descendants_paths
  after_update :destroy_replaced_embeddable, if: -> { embeddable_type_changed? }
  after_destroy :destroy_embeddable

  default_scope -> { order(:lft) }
  scope :published, -> { where(published: true) }
  scope :hidden, -> { where(published: false) }
  scope :menu_items, -> { where(menu_item: true) }

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

    def embedding(*types)
      types = Array(types).flatten.map { |type| type.to_s.classify }
      where(embeddable_type: types.one? ? types.first : types)
    end

    def embeddable_types
      EMBEDDABLE_TYPES
    end

    def template_types
      @@template_types ||= template_types_hash.values.freeze
    end

    def template_types_hash
      @@template_types_hash ||= Hash[*EMBEDDABLE_TYPES.map do |embeddable_type|
        embeddable_class = embeddable_type.constantize rescue nil
        if embeddable_class and embeddable_class.respond_to?(:template_type)
          [embeddable_type, embeddable_class.template_type]
        end
      end.compact.flatten].freeze
    end

    def without(page)
      if page.new_record?
        all
      else
        where.not(id: page.id)
      end
    end
  end

  def build_embeddable(attributes = {})
    raise 'invalid embeddable type' unless embeddable_class
    self.embeddable = embeddable_class.new(attributes)
  end

  def children_with_embedded(*types)
    children.embedding(*types).includes(:embeddable)
  end

  def embeddable_attributes=(attributes)
    raise 'no embeddable type specified' if embeddable_class.nil?
    if embeddable_type_changed? or new_record?
      build_embeddable(attributes)
    else
      self.embeddable.attributes = attributes
    end
  end

  def embeddable_class
    (embeddable_type.in?(self.class.embeddable_types) ? embeddable_type.constantize : nil)
  end

  def hidden?
    !published?
  end

  def template_class
    @template_class ||= template_type.try(:constantize)
  end

  def template_path
    template.try(:view_path) || template_class.try(:default).try(:view_path) || raise(Page::MissingTemplate.new(self))
  end

  def template_type
    self.class.template_types_hash[embeddable_type]
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

  def destroy_replaced_embeddable
    embeddable_type_was.constantize.destroy(embeddable_id_was)
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
    errors.add(:template_id, :invalid) if template.present? and template.class.name != template_type
  end
end
