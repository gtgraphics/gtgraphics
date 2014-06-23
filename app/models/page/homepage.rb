# == Schema Information
#
# Table name: homepage_pages
#
#  id          :integer          not null, primary key
#  template_id :integer
#

class Page < ActiveRecord::Base
  class Homepage < ActiveRecord::Base
    include Page::Embeddable
    
    acts_as_page_embeddable creatable: false, template_class: 'Template::Homepage'
  end
end
