# == Schema Information
#
# Table name: menu_item_records
#
#  id                    :integer          not null, primary key
#  menu_item_record_id   :integer
#  menu_item_record_type :string(255)
#

class MenuItem::Record < ActiveRecord::Base
  include MenuItemTarget
  
  RECORD_TYPES = %w(
    Album
    Image
    Page
  )
end
