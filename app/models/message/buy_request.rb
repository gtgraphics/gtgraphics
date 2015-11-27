# == Schema Information
#
# Table name: messages
#
#  id                :integer          not null, primary key
#  first_sender_name :string
#  last_sender_name  :string
#  sender_email      :string
#  subject           :string
#  body              :text
#  created_at        :datetime
#  delegator_id      :integer
#  type              :string           not null
#  ip                :string
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
