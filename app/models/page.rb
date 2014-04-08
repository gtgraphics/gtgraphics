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
#  indexable       :boolean          default(TRUE), not null
#  children_count  :integer          default(0), not null
#  published       :boolean          default(TRUE), not null
#

class Page < ActiveRecord::Base
  include Authorable
  include BatchTranslatable
  include Excludable
  include PersistenceContextTrackable
  include Regionable

  EMBEDDABLE_TYPES = %w(
    Page::Content
    Page::ContactForm
    Page::Homepage
    Page::Image
    Page::Project
    Page::Redirection
  ).freeze

  translates :title, :meta_description, :meta_keywords, fallbacks_for_empty_translations: true

  composed_of :slug, mapping: %w(slug to_s), allow_nil: true, converter: :new

  acts_as_authorable
  acts_as_batch_translatable
  acts_as_nested_set counter_cache: :children_count, dependent: :destroy

  belongs_to :embeddable, polymorphic: true, autosave: true

  # Destruction must be done via callback, because "dependent: :destroy" leads to an infinite loop
  validates :embeddable, presence: true
  validates :embeddable_type, inclusion: { in: EMBEDDABLE_TYPES }, allow_blank: true
  validates :slug, presence: { unless: :root? }, uniqueness: { scope: :parent_id, if: :slug_changed? }
  validates :path, presence: { unless: :root? }, uniqueness: { if: :path_changed? }
  validate :verify_parent_assignability, if: :parent_id_changed?
  validate :verify_root_uniqueness, if: :root?
  validate :verify_embeddable_type_was_convertible, on: :update, if: :embeddable_type_changed?

  before_validation :set_slug
  before_validation :set_path, if: -> { slug_changed? or parent_id_changed? }
  before_destroy :destroyable?
  around_save :update_descendants_paths
  around_update :destroy_replaced_embeddable
  after_destroy :destroy_embeddable

  default_scope -> { order(:lft) }
  scope :hidden, -> { where(published: false) }
  scope :indexable, -> { where(indexable: true) }
  scope :menu_items, -> { where(menu_item: true) }
  scope :primary, -> { where(depth: 1) }
  scope :published, -> { where(published: true) }

  delegate :name, to: :author, prefix: true, allow_nil: true
  delegate :name, to: :template, prefix: true, allow_nil: true
  delegate :meta_keywords, :meta_keywords=, to: :translation
  delegate :template, to: :embeddable, allow_nil: true

  EMBEDDABLE_TYPES.each do |embeddable_type|
    sanitized_type = embeddable_type.demodulize.underscore

    scope sanitized_type.pluralize, -> { where(embeddable_type: embeddable_type) }
    scope "except_#{sanitized_type.pluralize}", -> { where.not(embeddable_type: embeddable_type) }

    class_eval %{
      def #{sanitized_type}?
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
  end

  def ancestors_and_siblings
    self.class.where(parent_id: self.ancestors.ids << nil)
  end

  def build_embeddable(attributes = {})
    raise 'invalid embeddable type' unless embeddable_class
    self.embeddable = embeddable_class.new(attributes)
  end

  def children_with_embedded(*types)
    children.embedding(*types).includes(:embeddable)
  end

  def descendants_count
    self_and_descendants.pluck(:children_count).sum
  end

  def destroyable?
    !root?
  end

  def disable_in_menu
    self.menu_item = false
  end

  def disable_in_menu!
    update_column(:menu_item, false)
  end

  def enable_in_menu
    self.menu_item = true
  end

  def enable_in_menu!
    update_column(:menu_item, true)
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

  def hide
    self.published = false
  end

  def hide!
    update_column(:published, false)
  end

  def hidden?
    !published?
  end

  def publish
    self.published = true
  end

  def publish!
    update_column(:published, true)
  end

  def refresh_path!(include_descendants = false)
    if include_descendants
      transaction { self_and_descendants.each(&:refresh_path!) }
    else
      update_column(:path, generate_path)
    end
  end

  def self_and_ancestors_and_siblings
    self.class.where(parent_id: self.self_and_ancestors.ids << nil)
  end

  def supports_template?
    embeddable_class.try(:supports_template?) || false
  end

  def template_path
    template.try(:view_path)
  end

  def to_liquid
    attributes.slice(*%w(title slug path updated_at)).merge(
      'type' => embeddable_class.model_name.human,
      'author' => author,
      'template' => template_name,
      'children' => children.with_translations.to_a
    ).reverse_merge(embeddable.try(:to_liquid) || {})
  end

  def to_s
    title
  end

  private
  def destroy_embeddable
    embeddable.destroy
  end

  def destroy_replaced_embeddable
    embeddable_type_changed = self.embeddable_type_changed?
    yield
    embeddable_class_was.destroy(embeddable_id_was) if embeddable_type_changed
  end

  def generate_path
    if parent.present?
      path_parts = parent.self_and_ancestors.pluck(:slug) << slug.to_s
    else
      path_parts = [slug.to_s]
    end
    path_parts.reject!(&:blank?)
    File.join(path_parts)
  end

  def set_path
    self.path = generate_path
  end

  def set_previous_changes
    @previously_changed = changes
  end

  def set_slug
    self.slug = title(I18n.default_locale) if new_record? and slug.blank? and title.present?
    self.slug = '' if root?
  end

  def update_descendants_paths
    path_changed = self.path_changed?
    yield
    transaction { descendants.each(&:refresh_path!) } if path_changed
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
