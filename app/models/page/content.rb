# == Schema Information
#
# Table name: content_pages
#
#  id          :integer          not null, primary key
#  template_id :integer
#

class Page < ActiveRecord::Base
  class Content < ActiveRecord::Base
    include Page::Embeddable
    
    acts_as_page_embeddable template_class: 'Template::Content'
  end
end
