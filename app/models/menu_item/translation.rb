# == Schema Information
#
# Table name: menu_item_translations
#
#  id           :integer          not null, primary key
#  menu_item_id :integer          not null
#  locale       :string(255)      not null
#  created_at   :datetime
#  updated_at   :datetime
#  title        :string(255)
#

class MenuItem::Translation < ActiveRecord::Base
  include ::Translation

  validates :title, presence: true, if: :default_locale?

  def default_locale?
    locale == I18n.default_locale.to_s
  end
end
