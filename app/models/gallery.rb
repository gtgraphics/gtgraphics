# == Schema Information
#
# Table name: galleries
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#

class Gallery < ActiveRecord::Base
  include BatchTranslatable
  include Embeddable

  self.bound_to_page = true

  translates :title, :description, fallbacks_for_empty_translations: true

  accepts_nested_attributes_for :translations, allow_destroy: true

  def description_html
    template = Liquid::Template.parse(description)
    template.render(to_liquid).html_safe
  end

  def to_liquid
    page.attributes.slice(*%w(slug path)).merge('title' => title, 'children' => page.children)
  end

  def to_s
    title
  end
end