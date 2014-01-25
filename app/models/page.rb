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
#  embeddable_id   :integer
#  embeddable_type :string(255)
#  menu_item       :boolean          default(TRUE), not null
#  state           :string(255)      not null
#  indexable       :boolean          default(TRUE), not null
#  children_count  :integer          default(0), not null
#

class Page < ActiveRecord::Base
  include Authorable
  include BatchTranslatable
  include PersistenceContextTrackable

  STATES = %w(
    published
    hidden
    drafted
  ).freeze

  EMBEDDABLE_TYPES = %w(
    Page::Content
    Page::ContactForm
    Page::Homepage
    Page::Image
    Page::Project
    Page::Redirection
  ).freeze

  translates :title, :meta_description, :meta_keywords, fallbacks_for_empty_translations: true

  acts_as_authorable
  acts_as_batch_translatable
  acts_as_nested_set counter_cache: :children_count, dependent: :destroy

  belongs_to :embeddable, polymorphic: true, autosave: true, dependent: :destroy
  has_many :regions, dependent: :destroy, autosave: true

  validates :embeddable, presence: true
  validates :embeddable_type, inclusion: { in: EMBEDDABLE_TYPES }, allow_blank: true
  validates :slug, presence: { unless: :root? }, uniqueness: { scope: :parent_id, if: :slug_changed? }
  validates :path, presence: { unless: :root? }, uniqueness: { if: :path_changed? }
  validate :verify_parent_assignability, if: :parent_id_changed?
  validate :verify_root_uniqueness, if: :root?
  validate :verify_embeddable_type_was_convertible, on: :update, if: :embeddable_type_changed?

  before_validation :generate_slug
  before_validation :generate_path, if: :slug_changed?
  before_save :sanitize_regions
  before_destroy :destroyable?
  after_save :update_descendants_paths, if: :path_changed?
  after_update :destroy_replaced_embeddable, if: :embeddable_changed?

  default_scope -> { order(:lft) }
  scope :drafted, -> { with_state(:drafted) }
  scope :hidden, -> { with_state(:hidden) }
  scope :indexable, -> { where(indexable: true) }
  scope :menu_items, -> { where(menu_item: true) }
  scope :primary, -> { where(depth: 1) }
  scope :published, -> { with_state(:published) }

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

  delegate :name, to: :author, prefix: true, allow_nil: true
  delegate :name, to: :template, prefix: true, allow_nil: true
  delegate :meta_keywords, :meta_keywords=, to: :translation
  delegate :supports_template?, :supports_regions?, to: :embeddable_class, allow_nil: true

  EMBEDDABLE_TYPES.each do |embeddable_type|
    scope embeddable_type.demodulize.underscore.pluralize, -> { where(embeddable_type: embeddable_type) }

    class_eval %{
      def #{embeddable_type.demodulize.underscore}?
        embeddable_type == '#{embeddable_type}'
      end
    }
  end

  class << self
    def assignable_as_parent_of(page)
      where.not(id: page.self_and_descendants.pluck(:id))
    end

    def creatable_embeddable_classes
      @@creatable_embeddable_classes ||= embeddable_classes.select(&:creatable?).freeze
    end

    def embedding(*types)
      types = Array(types).flatten.map { |type| "Page::#{type.to_s.classify}" }
      where(embeddable_type: types.many? ? types : types.first)
    end

    def embeddable_classes
      @@embeddable_classes ||= embeddable_types.map(&:constantize).freeze
    end

    def embeddable_types
      EMBEDDABLE_TYPES
    end

    def states
      STATES.inject(ActiveSupport::HashWithIndifferentAccess.new) do |states, state|
        states.merge!(state => I18n.translate(state, scope: 'page.states'))
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

  def ancestors_and_siblings
    self.class.where(parent_id: self.ancestors.ids << nil)
  end

  def available_regions
    @available_regions ||= (template && template.region_definitions.pluck(:label)) || []
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
    raise 'invalid embeddable type' unless embeddable_class
    if attributes['id'].present?
      embeddable_id = attributes['id'].to_i
      self.embeddable = embeddable_class.find_by(id: embeddable_id) if self.embeddable_id != embeddable_id
    end
    build_embeddable if embeddable.nil?
    self.embeddable.attributes = attributes
  end

  def embeddable_class
    embeddable_type.in?(EMBEDDABLE_TYPES) ? embeddable_type.constantize : nil
  end

  def embeddable_class_was
    embeddable_type_was.try(:constantize)
  end

  def embeddable_changed?
    embeddable_type_changed? or embeddable_id_changed?
  end

  def has_children?
    children_count > 0
  end

  def hidden?
    !published?
  end

  def self_and_ancestors_and_siblings
    self.class.where(parent_id: self.self_and_ancestors.ids << nil)
  end

  def state_name
    I18n.translate(state, scope: 'page.states')
  end

  def template
    embeddable.template if supports_template?
  end

  def template_path
    template.try(:view_path)
  end

  def to_liquid
    attributes.slice(*%w(title slug path updated_at)).merge(
      'type' => embeddable_class.model_name.human,
      'author' => author,
      'template' => template_name,
      'children' => children.with_translations(I18n.locale).to_a
    ).reverse_merge(embeddable.try(:to_liquid) || {})
  end

  def to_s
    title
  end

  def update_path!
    generate_path
    save!
  end

  private
  def destroy_replaced_embeddable
    embeddable_class_was.destroy(embeddable_id_was) if embeddable_type_changed?
  end

  def generate_path
    if parent.present?
      path_parts = parent.self_and_ancestors.pluck(:slug) << slug
    else
      path_parts = [slug]
    end
    path_parts.reject!(&:blank?)
    self.path = File.join(path_parts)
  end

  def generate_slug
    self.slug = title(I18n.default_locale) if new_record? and slug.blank? and title.present?
    self.slug = slug.parameterize if slug.present?
  end

  def sanitize_regions
    # If changing the embeddable type, migrates the regions to the defined regions on the new template
    if supports_regions?
      # self.regions = regions.slice(available_regions) # TODO
      
    else
      regions.destroy_all
    end
  end

  def update_descendants_paths
    transaction { descendants.each(&:update_path!) }
  end

  def verify_embeddable_type_was_convertible
    errors.add(:embeddable_type, :invalid) unless embeddable_class_was.convertible?
  end

  def verify_parent_assignability
    errors.add(:parent_id, :invalid) if self_and_descendants.pluck(:id).include?(parent_id)
  end

  def verify_root_uniqueness
    errors.add(:parent_id, :taken) if self.class.roots.without(self).exists?
  end
end
