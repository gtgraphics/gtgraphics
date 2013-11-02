# == Schema Information
#
# Table name: content_region_definitions
#
#  id          :integer          not null, primary key
#  template_id :integer
#  label       :string(255)
#

class Template < ActiveRecord::Base
  class Content < Template
    class Region < ActiveRecord::Base
      self.table_name = 'content_region_definitions'

      belongs_to :template, class_name: '::Template::Content'
      has_many :regions, class_name: '::Content::Region', foreign_key: :definition_id, dependent: :destroy
    end
  end
end
