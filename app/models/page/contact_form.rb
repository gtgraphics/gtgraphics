# == Schema Information
#
# Table name: contact_form_pages
#
#  id          :integer          not null, primary key
#  template_id :integer
#

class Page < ActiveRecord::Base
  class ContactForm < ActiveRecord::Base
    include PageEmbeddable
    
    acts_as_page_embeddable template_class: 'Template::ContactForm'

    has_and_belongs_to_many :recipients, class_name: 'User', join_table: 'contact_form_recipients', foreign_key: :contact_form_page_id, association_foreign_key: :recipient_id

    validates :recipients, presence: true
  end
end
