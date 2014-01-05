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
  include BatchTranslatable
  include PersistenceContextTrackable

  DEFAULT_EMBEDDABLE_TYPE = 'Content'

  STATES = %w(
    published
    hidden
    drafted
  ).freeze

  EMBEDDABLE_TYPES = %w(
    Page::ContactForm
    Page::Homepage
    Page::Image
    Page::Project
    Page::Redirection
  ).freeze

  translates :contents, :meta_description, :meta_keywords, fallbacks_for_empty_translations: true

  store :contents

  acts_as_authorable
  acts_as_batch_translatable
  acts_as_nested_set

  belongs_to :embeddable, polymorphic: true, autosave: true
  belongs_to :template, inverse_of: :pages
  has_many :regions, dependent: :destroy, inverse_of: :page

  validates :embeddable_type, inclusion: { in: EMBEDDABLE_TYPES }, allow_blank: true
  validates :template_id, presence: true
  validates :slug, presence: { unless: :root? }, uniqueness: { scope: :parent_id }
  validates :path, presence: { unless: :root? }, uniqueness: true, if: -> { slug.present? }
  validate :validate_parent_assignability
  validate :validate_template_type
  validate :validate_no_root_exists, if: :root?
  validate :validate_embeddable_type_was_convertible, on: :update, if: -> { embeddable_type_was.present? }

  before_validation :generate_slug
  before_validation :generate_path, if: -> { slug.present? }
  before_destroy :destroyable?
  after_save :update_descendants_paths
  after_update :destroy_replaced_embeddable

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

  delegate :name, to: :author, prefix: true, allow_nil: true
  delegate :region_definitions, to: :template

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
      types = Array(types).flatten.map { |type| type.to_s.classify }
      where(embeddable_type: types.one? ? types.first : types)
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

  def hidden?
    !published?
  end

  def render_region(name)
    regions_hash.fetch(name, '').html_safe
  end

  def regions_hash
    regions.inject(ActiveSupport::HashWithIndifferentAccess.new) do |regions_hash, region|
      regions_hash.merge!(region.definition_label => region.body)
    end.freeze
  end

  def state_name
    I18n.translate(state, scope: 'page.states')
  end

  def template_path
    template.try(:view_path)
  end

  def update_path!
    generate_path
    save!
  end

  private
  def destroy_replaced_embeddable
    embeddable_class_was.destroy(embeddable_id_was) if embeddable_type_was and embeddable_id_was
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

  def update_descendants_paths
    transaction { descendants.each(&:update_path!) }
  end

  def validate_embeddable_type_was_convertible
    errors.add(:embeddable_type, :invalid) unless embeddable_class_was.convertible?
  end

  def validate_no_root_exists
    errors.add(:parent_id, :taken) if self.class.roots.without(self).exists?
  end

  def validate_parent_assignability
    errors.add(:parent_id, :invalid) if self_and_descendants.pluck(:id).include?(parent_id)
  end
end