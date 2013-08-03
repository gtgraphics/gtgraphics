# == Schema Information
#
# Table name: album_translations
#
#  id         :integer          not null, primary key
#  album_id   :integer          not null
#  locale     :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#  title      :string(255)
#

class Album::Translation
  validates :title, presence: true
end
