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

  translates :title, :content, fallbacks_for_empty_translations: true

  acts_as_batch_translatable
  acts_as_page_embeddable destroy_with_page: true

  def content_html(locale = I18n.locale)
    template = Liquid::Template.parse(self.content(locale))
    template.render(to_liquid).html_safe
  end

  def to_liquid
    page.attributes.slice(*%w(slug path)).merge('title' => title, 'children' => page.children)
  end
end
