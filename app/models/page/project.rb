class Page < ActiveRecord::Base
  class Project < ActiveRecord::Base
    include BatchTranslatable
    include PageEmbeddable

    translates :name, :description, fallbacks_for_empty_translations: true

    acts_as_batch_translatable
    acts_as_page_embeddable template_class: 'Template::Project'
  end
end