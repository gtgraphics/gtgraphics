# == Schema Information
#
# Table name: project_pages
#
#  id          :integer          not null, primary key
#  template_id :integer
#  client_name :string(255)
#  client_url  :string(255)
#  released_on :date
#

class Page < ActiveRecord::Base
  class Project < ActiveRecord::Base
    include BatchTranslatable
    include PageEmbeddable

    acts_as_page_embeddable template_class: 'Template::Project'

    translates :name, :description, fallbacks_for_empty_translations: true
    acts_as_batch_translatable
  end
end
