# == Schema Information
#
# Table name: contact_forms
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#

class ContactForm < ActiveRecord::Base
  include PageEmbeddable

  acts_as_page_embeddable destroy_with_page: true

  has_and_belongs_to_many :recipients, class_name: 'User', join_table: 'contact_form_recipients', foreign_key: 'contact_form_id', association_foreign_key: 'recipient_id'
end
