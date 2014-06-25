# == Schema Information
#
# Table name: content_pages
#
#  id          :integer          not null, primary key
#  template_id :integer
#

class Page < ActiveRecord::Base
  class Content < ActiveRecord::Base
    include Page::Concrete

    acts_as_concrete_page
  end
end
