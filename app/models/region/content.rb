# == Schema Information
#
# Table name: region_contents
#
#  id :integer          not null, primary key
#

class Region < ActiveRecord::Base
  class Content < ActiveRecord::Base
    include BatchTranslatable

    translates :body, fallbacks_for_empty_translations: true

    acts_as_batch_translatable

    has_one :region, as: :concrete_region, dependent: :destroy
  end
end