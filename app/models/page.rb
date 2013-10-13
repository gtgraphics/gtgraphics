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
  acts_as_nested_set

  belongs_to :template, class_name: 'Page::Template'

  translates :title, :content

  accepts_nested_attributes_for :translations, allow_destroy: true

  validates :slug, presence: true, uniqueness: { scope: :parent_id }
  validates :path, presence: true, uniqueness: true, if: -> { slug.present? }

  after_initialize :set_default_template, if: -> { template.blank? }
  before_validation :generate_path

  class Translation < Globalize::ActiveRecord::Translation
    validates :title, presence: true
  end

  private
  def generate_path
    self.path = [ancestors.collect(&:slug) + slug].join('/') if slug.present?
  end

  def set_default_template
    self.template = Page::Template.default
  end
end
