# == Schema Information
#
# Table name: contents
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#

class Content < ActiveRecord::Base
  include BatchTranslatable
  include Embeddable

  translates :title, :content, fallbacks_for_empty_translations: true

  accepts_nested_attributes_for :translations, allow_destroy: true

  #class Template < ::Template
  #end

  class Translation < Globalize::ActiveRecord::Translation
    validates :title, presence: true
  end

  def content_html
    template = Liquid::Template.parse(content)
    template.render(to_liquid).html_safe
  end

  def to_liquid
    page.attributes.slice(*%w(slug path)).merge('title' => title, 'children' => page.children)
  end
end
