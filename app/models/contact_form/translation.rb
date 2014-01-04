# == Schema Information
#
# Table name: contact_form_translations
#
#  id              :integer          not null, primary key
#  contact_form_id :integer          not null
#  locale          :string(255)      not null
#  created_at      :datetime
#  updated_at      :datetime
#  title           :string(255)
#

class ContactForm < ActiveRecord::Base
  class Translation < Globalize::ActiveRecord::Translation
    validates :title, presence: true
  end
end
