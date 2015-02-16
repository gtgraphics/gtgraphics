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
#

class Message < ActiveRecord::Base
  class BuyRequest < Message
    belongs_to :image, foreign_key: :delegator_id

    def delegator
      image
    end

    protected

    def build_recipiences
      recipiences.build(recipient: image.author)
    end
  end
end
