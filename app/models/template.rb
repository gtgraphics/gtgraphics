# == Schema Information
#
# Table name: templates
#
#  id                      :integer          not null, primary key
#  type                    :string(255)
#  screenshot_file_name    :string(255)
#  screenshot_content_type :string(255)
#  screenshot_file_size    :integer
#  screenshot_updated_at   :datetime
#  default                 :boolean          default(FALSE), not null
#

class Template < ActiveRecord::Base
  include BatchTranslatable

  translates :name, :description, fallbacks_for_empty_translations: true

  accepts_nested_attributes_for :translations, allow_destroy: true
end
