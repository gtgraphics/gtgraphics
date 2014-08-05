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
#  hits_count      :integer          default(0), not null
#  permalink       :string(6)        not null
#  metadata        :text
#

class Page < ActiveRecord::Base
  include Excludable
  include HitCountable
  include NestedSetRepresentable
  include Ownable
  include Page::Abstract
  include Page::MenuContainable
  include Page::Templatable
  include Page::RouteCacheable
  include Page::UrlAccessible
  include PersistenceContextTrackable
  include Publishable
  include Translatable

  translates :title, :meta_description, :meta_keywords, fallbacks_for_empty_translations: true
  sanitizes :title, with: :squish

  has_owner :author

  has_many :redirections, class_name: 'Page::Redirection', foreign_key: :destination_page_id, 
                          inverse_of: :destination_page, dependent: :destroy

  validates :title, presence: true
  validates :meta_description, :meta_keywords, absence: true, unless: :support_templates?
  validate :verify_root_uniqueness, if: :root?

  before_validation :set_title, prepend: true, if: -> { title.blank? }
  before_destroy :destroyable?

  default_scope -> { order(:lft) }
  scope :indexable, -> { where(indexable: true) }
  scope :primary, -> { where(depth: 1) }

  delegate :name, to: :author, prefix: true, allow_nil: true

  store :metadata

  def self.search(query)
    if query.present?
      terms = query.to_s.split.uniq.map { |term| "%#{term}%" }
      ransack(translations_title_or_path_matches_any: terms).result.uniq
    else
      all
    end
  end

  def destroyable?
    !root?
  end

  def to_liquid
    attributes.slice(*%w(title slug path updated_at)).merge(
      'type' => embeddable_class.model_name.human,
      'author' => author,
      'template' => template_name
    ).reverse_merge(embeddable.try(:to_liquid) || {})
  end

  def to_s
    title
  end

  private
  def set_title
    if embeddable and embeddable.respond_to?(:to_title)
      self.title = embeddable.to_title
    end
  end

  def verify_root_uniqueness
    errors.add(:parent_id, :taken) if self.class.roots.without(self).exists?
  end
end
