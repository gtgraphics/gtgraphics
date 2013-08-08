# == Schema Information
#
# Table name: album_translations
#
#  id       :integer          not null, primary key
#  album_id :integer          not null
#  locale   :string(2)        not null
#  title    :string(255)
#

class Album::Translation < ActiveRecord::Base
  include ::Translation

  validates :title, presence: true, if: :default_locale?

  def default_locale?
    locale == I18n.default_locale.to_s
  end
end
