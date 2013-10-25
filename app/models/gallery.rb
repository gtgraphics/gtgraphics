# == Schema Information
#
# Table name: galleries
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#

class Gallery < ActiveRecord::Base
  include BatchTranslatable
  include Embeddable

  self.bound_to_page = true

  translates :title, :description, fallbacks_for_empty_translations: true

  accepts_nested_attributes_for :translations, allow_destroy: true

  #def title
  #  "Galerie"
  #end

  def to_s
    title
  end
end
