class Project < ActiveRecord::Base
  include HtmlContainable

  translates :name, :description, fallbacks_for_empty_translations: true

  acts_as_batch_translatable
  acts_as_html_containable :description
  acts_as_page_embeddable destroy_with_page: true

  def to_liquid
    {} # TODO
  end
end
