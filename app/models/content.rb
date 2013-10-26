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

  self.bound_to_page = true

  translates :title, :content, fallbacks_for_empty_translations: true

  accepts_nested_attributes_for :translations, allow_destroy: true
  acts_as_batch_translated

  def content_html
    template = Liquid::Template.parse(content)
    template.render(to_liquid).html_safe
  end

  def to_liquid
    page.attributes.slice(*%w(slug path)).merge('title' => title, 'children' => page.children)
  end
end
