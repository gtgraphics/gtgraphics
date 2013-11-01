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
  include Templatable

  self.bound_to_page = true
  self.template_type = 'Template::Content'.freeze

  translates :title, :content, fallbacks_for_empty_translations: true

  acts_as_batch_translatable

  def content_html(locale = I18n.locale)
    template = Liquid::Template.parse(self.content(locale))
    template.render(to_liquid).html_safe
  end
end
