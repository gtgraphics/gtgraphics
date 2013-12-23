# == Schema Information
#
# Table name: messages
#
#  id                :integer          not null, primary key
#  recipient_id      :integer
#  first_sender_name :string(255)
#  last_sender_name  :string(255)
#  sender_email      :string(255)
#  subject           :string(255)
#  body              :text
#  read              :boolean          default(FALSE)
#  created_at        :datetime
#

class Message < ActiveRecord::Base
  include Sortable

  belongs_to :recipient, class_name: 'User'

  validates :recipient_id, presence: true
  validates :first_sender_name, presence: true
  validates :last_sender_name, presence: true
  validates :sender_email, presence: true, email: true
  validates :body, presence: true

  after_create :send_notification_email

  default_scope -> { order(:created_at).reverse_order }
  scope :read, -> { where(read: true) }
  scope :unread, -> { where(read: false) }

  acts_as_sortable do |by|
    by.created_at default: true, primary: :descending
    by.read
    by.sender_name { |dir| [arel_table[:first_sender_name].send(dir.to_sym), arel_table[:last_sender_name].send(dir.to_sym)] }
    by.subject
  end

  delegate :name, to: :recipient, prefix: true
  alias_method :full_recipient_name, :recipient_name

  class << self
    def older_than(time)
      where(arel_table[:created_at].lt(time.ago))
    end
  end

  def full_sender_name
    "#{first_sender_name} #{last_sender_name}".strip
  end
  alias_method :sender_name, :full_sender_name

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
