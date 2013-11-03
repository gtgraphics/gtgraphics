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
  include PageEmbeddable
  include Templatable

  self.template_type = 'Template::Content'.freeze

  translates :title, :body, fallbacks_for_empty_translations: true

  acts_as_batch_translatable
  acts_as_page_embeddable destroy_with_page: true

  def body_html(locale = I18n.locale)
    template = Liquid::Template.parse(self.body(locale))
    template.render(to_liquid).html_safe
  end

  #def body_html(region = nil, locale = I18n.locale)
  #  if region.nil? 
  #    body = self.body(locale)
  #  else
  #    body = self.translation_for(locale).regions.includes(:definition).where(region_definitions: { label: region }).first.try(:body)
  #  end
  #  template = Liquid::Template.parse(body)
  #  template.render(to_liquid).html_safe
  #end

  def to_liquid
    page.attributes.slice(*%w(slug path)).merge('title' => title, 'children' => page.children)
  end
end
