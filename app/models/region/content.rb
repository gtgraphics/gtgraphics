# == Schema Information
#
# Table name: region_contents
#
#  id :integer          not null, primary key
#

class Region < ActiveRecord::Base
  class Content < ActiveRecord::Base
    include BatchTranslatable

    has_one :region, as: :regionable, dependent: :destroy
    
    translates :body, fallbacks_for_empty_translations: true

    acts_as_batch_translatable
  end
end
