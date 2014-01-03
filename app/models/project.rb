# == Schema Information
#
# Table name: projects
#
#  id          :integer          not null, primary key
#  released_on :date
#  created_at  :datetime
#  updated_at  :datetime
#

class Project < ActiveRecord::Base
  include BatchTranslatable
  include HtmlContainable
  include PageEmbeddable
  include Templatable

  self.template_type = 'Template::Project'.freeze

  translates :name, :description, :client_name, :client_url, fallbacks_for_empty_translations: true

  has_many :project_images, class_name: 'Project::Image', dependent: :destroy
  has_many :images, through: :project_images

  acts_as_batch_translatable
  acts_as_html_containable :description
  acts_as_page_embeddable destroy_with_page: true

  def to_liquid
    page.attributes.slice(*%w(slug path)).merge('name' => name, 'children' => page.children)
  end
end
