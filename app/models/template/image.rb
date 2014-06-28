# == Schema Information
#
# Table name: templates
#
#  id          :integer          not null, primary key
#  file_name   :string(255)
#  type        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  name        :string(255)
#  description :text
#

class Template < ActiveRecord::Base
  class Image < Template
    acts_as_concrete_template
  end
end
