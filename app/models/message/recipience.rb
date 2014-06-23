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
    include Sortable

    belongs_to :message, inverse_of: :recipiences
    belongs_to :recipient, class_name: 'User'

    validates :recipient_id, presence: true

    after_destroy :destroy_message

    scope :read, -> { where(read: true) }
    scope :unread, -> { where(read: false) }

    delegate :first_sender_name, :last_sender_name, :sender, :sender_name, :sender_email, :subject, :body, :created_at, to: :message

    acts_as_sortable do |by|
      by.created_at(default: true, primary: :descending) { |dir| Message.arel_table[:created_at].send(dir.to_sym) }
      by.read
      by.sender_name { |dir| [Message.arel_table[:first_sender_name].send(dir.to_sym), Message.arel_table[:last_sender_name].send(dir.to_sym)] }
      by.subject { |dir| Message.arel_table[:subject].send(dir.to_sym) }
    end

    def mark_read!
      update_column(:read, true) if unread?
      self
    end

    def mark_unread!
      update_column(:read, false) if read?
      self
    end

    def unread?
      !read?
    end

    private
    def destroy_message
      message.destroy if message.recipiences.empty?
    end
  end
end
