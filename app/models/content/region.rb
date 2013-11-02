# == Schema Information
#
# Table name: content_regions
#
#  id                     :integer          not null, primary key
#  content_translation_id :integer
#  definition_id          :integer
#  content                :text
#

class Content < ActiveRecord::Base
  class Region < ActiveRecord::Base
    belongs_to :content_translation, class_name: 'Content::Translation'
    belongs_to :definition, class_name: 'Template::Content::Region'
  end
end
