# == Schema Information
#
# Table name: menu_item_translations
#
#  id           :integer          not null, primary key
#  menu_item_id :integer          not null
#  locale       :string(2)        not null
#  title        :string(255)
#

class MenuItem::Translation < ActiveRecord::Base
  include ::Translation

  validates :title, presence: true, if: :default_locale?
end
