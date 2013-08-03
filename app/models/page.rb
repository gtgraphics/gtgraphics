# == Schema Information
#
# Table name: pages
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  slug       :string(255)
#  content    :text
#  author_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

class Page < ActiveRecord::Base
end
