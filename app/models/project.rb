# == Schema Information
#
# Table name: projects
#
#  id         :integer          not null, primary key
#  url        :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Project < ActiveRecord::Base
  include BatchTranslatable
  include HtmlContainable
  include PageEmbeddable

  translates :name, :description, :client_name, :client_url, fallbacks_for_empty_translations: true

  acts_as_batch_translatable
  acts_as_html_containable :description
  acts_as_page_embeddable destroy_with_page: true

  validates :url, url: true, allow_blank: true

  def to_liquid
    page.attributes.slice(*%w(slug path)).merge('name' => name, 'children' => page.children)
  end
end
