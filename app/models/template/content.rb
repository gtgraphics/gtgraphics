# == Schema Information
#
# Table name: templates
#
#  id          :integer          not null, primary key
#  file_name   :string
#  type        :string
#  created_at  :datetime
#  updated_at  :datetime
#  name        :string
#  description :text
#  position    :integer          not null
#

class Template < ActiveRecord::Base
  class Content < Template
    acts_as_concrete_template
  end
end
