class Message < ActiveRecord::Base
  class Recipience < ActiveRecord::Base
    include Sortable

    belongs_to :message, inverse_of: :recipiences
    belongs_to :recipient, class_name: 'User'

    validates :recipient_id, presence: true

    after_create :send_notification_email

    scope :read, -> { where(read: true) }
    scope :unread, -> { where(read: false) }

    acts_as_sortable do |by|
      by.created_at default: true, primary: :descending
      by.read
      by.sender_name { |dir| [arel_table[:first_sender_name].send(dir.to_sym), arel_table[:last_sender_name].send(dir.to_sym)] }
      by.subject
    end

    def mark_read!
      update_column(:read, true)
    end

    def mark_unread!
      update_column(:read, false)
    end

    def unread?
      !read?
    end

    private
    def send_notification_email
      # TODO
    end
  end
end