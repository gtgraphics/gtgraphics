# == Schema Information
#
# Table name: homepage_pages
#
#  id          :integer          not null, primary key
#  template_id :integer
#

class Page < ActiveRecord::Base
  class Homepage < ActiveRecord::Base
    include Page::Concrete
    
    acts_as_concrete_page do |config|
      config.creatable = false
    end
  end
end
