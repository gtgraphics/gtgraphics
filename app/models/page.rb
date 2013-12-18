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
#  embeddable_id   :integer
#  embeddable_type :string(255)
#  menu_item       :boolean          default(TRUE), not null
#  state           :string(255)      not null
#

class Page < ActiveRecord::Base
  include Authorable

  EMBEDDABLE_TYPES = %w(
    ContactForm
    Content
    Gallery
    Homepage
    Image
    Redirection
  ).freeze

  RESERVED_SLUGS = %w(
    images
    albums
    galleries
  ).freeze

  STATES = %w(
    published
    hidden
    drafted
  ).freeze

  acts_as_authorable
  acts_as_nested_set

  belongs_to :embeddable, polymorphic: true, autosave: true
  belongs_to :template, inverse_of: :pages
  has_many :regions, dependent: :destroy, inverse_of: :page

  validates :embeddable, presence: true
  validates :embeddable_type, presence: true, inclusion: { in: EMBEDDABLE_TYPES }
  validates :template_id, presence: true, if: :support_template?
  validates :slug, presence: { unless: :root? }, uniqueness: { scope: :parent_id }, exclusion: { in: RESERVED_SLUGS, if: :root? }
  validates :path, presence: { unless: :root? }, uniqueness: true, if: -> { slug.present? }
  validate :validate_parent_assignability
  validate :validate_template_type
  validate :validate_no_root_exists, if: :root?

  after_initialize :set_default_template, if: -> { support_template? and template.blank? }
  before_validation :generate_slug
  before_validation :generate_path, if: -> { slug.present? }
  after_save :update_descendants_paths
  after_update :destroy_replaced_embeddables, if: :embeddable_changed?
  after_update :migrate_or_destroy_regions, if: -> { embeddable_changed? and support_regions? }
  before_destroy :destroyable?
  after_destroy :destroy_embeddable

  default_scope -> { order(:lft) }
  scope :drafted, -> { with_state(:drafted) }
  scope :hidden, -> { with_state(:hidden) }
  scope :in_main_menu, -> { published.menu_items.where(depth: 1) }
  scope :menu_items, -> { where(menu_item: true) }
  scope :published, -> { with_state(:published) }
  scope :with_translations, -> { includes(embeddable: :translations) }

  state_machine :state, initial: :drafted do
    state :published
    state :hidden
    state :drafted

    event :publish do
      transition all => :published
    end
    event :draft do
      transition all => :drafted
    end
    event :hide do
      transition all => :hidden
    end
  end

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
      super "Missing template for #{page.embeddable_type} in #{page.inspect}"
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

    def states
      @@states ||= STATES.inject(ActiveSupport::HashWithIndifferentAccess.new) do |states, state|
        states.merge!(state => I18n.translate(state, scope: 'page.states'))
      end
    end

    def template_types
      @@template_types ||= template_types_hash.values.freeze
    end

    def template_types_hash
      @@template_types_hash ||= EMBEDDABLE_TYPES.inject({}) do |embeddable_types, embeddable_type|
        embeddable_class = embeddable_type.constantize rescue nil
        if embeddable_class and embeddable_class.respond_to?(:template_type)
          embeddable_types[embeddable_type] = embeddable_class.template_type
        end
        embeddable_types
      end.freeze
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

  def destroyable?
    !root?
  end

  def embeddable_attributes=(attributes)
    raise 'no embeddable type specified' if embeddable_class.nil?
    if embeddable.nil? or embeddable_type_changed?
      build_embeddable(attributes)
    else
      self.embeddable.attributes = attributes
    end
  end

  def embeddable_class
    embeddable_type.in?(EMBEDDABLE_TYPES) ? embeddable_type.constantize : nil
  end

  def embeddable_class_was
    embeddable_type_was.constantize
  end

  def embeddable_changed?
    embeddable_type_changed? or embeddable_id_changed?
  end

  def hidden?
    !published?
  end

  def regions_hash(locale = I18n.locale)
    regions.inject(ActiveSupport::HashWithIndifferentAccess.new) do |regions_hash, region|
      if body = region.body(locale)
        regions_hash[region.definition_label] = body
      end
      regions_hash
    end
  end

  def state_name(locale = I18n.locale)
    I18n.translate(state, scope: 'page.states', locale: locale)
  end

  def support_template?
    self.class.template_types_hash.key?(embeddable_type)
  end
  alias_method :support_regions?, :support_template?

  def template_class
    @template_class ||= template_type.try(:constantize)
  end

  def template_path
    template.try(:view_path) || raise(MissingTemplate.new(self))
  end

  def template_type
    self.class.template_types_hash[embeddable_type]
  end

  def title(locale = I18n.locale)
    embeddable.try(:title, locale) || embeddable.try(:title)
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

  def destroy_replaced_embeddables
    # FIXME Translations are not removed when changing to another embeddable type, then back and then the form gets submitted
    embeddable_class_was.destroy(embeddable_id_was) if embeddable_class_was.bound_to_page?
  end

  def generate_path
    if parent.present?
      path_parts = parent.self_and_ancestors.collect(&:slug) << slug
    else
      path_parts = [slug]
    end
    path_parts.reject!(&:blank?)
    self.path = File.join(*path_parts)
  end

  def generate_slug
    self.slug = title(I18n.default_locale) if new_record? and slug.blank? and title.present?
    self.slug = slug.parameterize if slug.present?
  end

  def migrate_or_destroy_regions
    if template_id and template_id_was     
      region_definitions = template.region_definitions.to_a
      region_definition_labels = region_definitions.collect(&:label)
      destroyable_region_ids = []
      prev_regions = regions.includes(:definition).where(region_definitions: { template_id: template_id_was })
      prev_regions.each do |region|
        if region.label.in?(region_definition_labels)
          region.definition = region_definitions.find { |definition| definition.label == region.label }
          region.save!
        else
          destroyable_region_ids << region.id
        end
      end
      Region.destroy_all(id: destroyable_region_ids)
    end
  end

  def set_default_template
    self.template = template_class.default
  end

  def update_descendants_paths
    transaction { descendants.each(&:update_path!) }
  end

  def validate_no_root_exists
    errors.add(:parent_id, :taken) if self.class.roots.without(self).any?
  end

  def validate_parent_assignability
    errors.add(:parent_id, :invalid) if self_and_descendants.pluck(:id).include?(parent_id)
  end

  def validate_template_type
    errors.add(:template_id, :invalid) if template.present? and template.class.name != template_type
  end
end
