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
  # include BatchTranslatable
  include Excludable
  include NestedSetRepresentable
  include Ownable
  include Page::Abstract
  include Page::MenuContainable
  include Page::Templatable
  include Page::UrlAccessible
  include PersistenceContextTrackable
  include Publishable

  translates :title, :meta_description, :meta_keywords, fallbacks_for_empty_translations: true
  sanitizes :title, with: :squish

  has_owner :author

  validates :title, presence: true
  validate :verify_root_uniqueness, if: :root?

  before_destroy :destroyable?

  default_scope -> { order(:lft) }
  scope :indexable, -> { where(indexable: true) }
  scope :primary, -> { where(depth: 1) }

  delegate :name, to: :author, prefix: true, allow_nil: true
  delegate :name, to: :template, prefix: true, allow_nil: true
  delegate :meta_keywords, :meta_keywords=, to: :translation

  def self.search(query)
    if query.present?
      terms = query.to_s.split.uniq.map { |term| "%#{term}%" }
      ransack(translations_title_or_path_matches_any: terms).result
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
  def verify_root_uniqueness
    errors.add(:parent_id, :taken) if self.class.roots.without(self).exists?
  end
end
