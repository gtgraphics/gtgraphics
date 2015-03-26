# == Schema Information
#
# Table name: messages
#
#  id                :integer          not null, primary key
#  first_sender_name :string(255)
#  last_sender_name  :string(255)
#  sender_email      :string(255)
#  subject           :string(255)
#  body              :text
#  created_at        :datetime
#  delegator_id      :integer
#  type              :string(255)      not null
#  ip                :string(255)
#

class Message < ActiveRecord::Base
  class Contact < Message
    belongs_to :contact_form, class_name: 'Page::ContactForm',
                              foreign_key: :delegator_id

    validates :body, presence: true

    def delegator
      contact_form
    end

    protected

    def build_recipiences
      contact_form.recipients.each do |recipient|
        recipiences.build(recipient: recipient)
      end
    end
  end
end
