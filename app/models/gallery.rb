# == Schema Information
#
# Table name: galleries
#
#  id           :integer          not null, primary key
#  slug         :string(255)      not null
#  created_at   :datetime
#  updated_at   :datetime
#  images_count :integer          default(0), not null
#

class Gallery < ActiveRecord::Base
  include BatchTranslatable
  include Embeddable

  self.bound_to_page = true

  translates :title

  def title
    "Galerie"
  end

  def to_s
    title
  end
end
