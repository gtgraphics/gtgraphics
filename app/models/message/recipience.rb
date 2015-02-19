# == Schema Information
#
# Table name: message_recipiences
#
#  id           :integer          not null, primary key
#  message_id   :integer
#  recipient_id :integer
#  read         :boolean          default(FALSE), not null
#

class Message < ActiveRecord::Base
  class Recipience < ActiveRecord::Base
    include PersistenceContextTrackable

    belongs_to :message, inverse_of: :recipiences
    belongs_to :recipient, class_name: 'User'

    validates :recipient_id, presence: true

    after_destroy :destroy_message_if_unreferenced

    scope :read, -> { where(read: true) }
    scope :unread, -> { where(read: false) }

    delegate :first_sender_name, :last_sender_name, :sender, :sender_name,
             :sender_email, :subject, :body, :created_at, to: :message

    def mark_read!
      tap { update_column(:read, true) if unread? }
    end

    def mark_unread!
      tap { update_column(:read, false) if read? }
    end

    def unread?
      !read?
    end

    private

    def destroy_message_if_unreferenced
      message.destroy if message.recipiences.empty?
    end
  end
end
