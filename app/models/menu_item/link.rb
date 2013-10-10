# == Schema Information
#
# Table name: menu_item_links
#
#  id  :integer          not null, primary key
#  url :string(255)
#

class MenuItem::Link < ActiveRecord::Base
  has_one :menu_item

  def to_s
    url
  end
end
