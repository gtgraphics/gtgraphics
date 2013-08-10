# == Schema Information
#
# Table name: menu_item_links
#
#  id  :integer          not null, primary key
#  url :string(255)
#

class MenuItem::Link < ActiveRecord::Base
  include MenuItemTarget
end
