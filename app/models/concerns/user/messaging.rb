class User < ActiveRecord::Base
  module Messaging
    extend ActiveSupport::Concern

    included do
      has_many :message_recipiences, class_name: 'Message::Recipience', foreign_key: :recipient_id, dependent: :destroy
      has_many :messages, -> { readonly }, through: :message_recipiences
      
      has_and_belongs_to_many :addressed_contact_forms, class_name: 'Page::ContactForm',
                                                        join_table: 'contact_form_recipients',
                                                        foreign_key: :recipient_id,
                                                        association_foreign_key: :contact_form_page_id
    end
  end
end