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
  include HtmlContainable
  include PageEmbeddable
  include Templatable

  self.template_type = 'Template::Content'.freeze

  translates :title, :body, fallbacks_for_empty_translations: true

  acts_as_batch_translatable
  acts_as_page_embeddable destroy_with_page: true
end
