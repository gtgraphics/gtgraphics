# == Schema Information
#
# Table name: pages
#
#  id         :integer          not null, primary key
#  slug       :string(255)
#  author_id  :integer
#  created_at :datetime
#  updated_at :datetime
#  template   :string(255)
#  path       :string(255)
#  parent_id  :integer
#  lft        :integer
#  rgt        :integer
#  depth      :integer
#

class Page < ActiveRecord::Base
  acts_as_nested_set

  translates :title, :content

  accepts_nested_attributes_for :translations

  validates :slug, presence: true, uniqueness: { scope: :parent_id }
  validates :path, presence: true, uniqueness: true, if: -> { slug.present? }

  before_validation :generate_path

  class Translation < Globalize::ActiveRecord::Translation
    validates :title, presence: true
  end

  class << self
    def templates
      @@templates ||= Dir[Rails.root.join('app/views/pages/templates/*')].collect { |filename| File.basename(filename).split('.').first }.sort
    end
  end

  private
  def generate_path
    self.path = [ancestors.collect(&:slug) + slug].join('/') if slug.present?
  end
end
