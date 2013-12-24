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
#  fingerprint       :string(255)
#

class Message < ActiveRecord::Base
  include Sortable

  # ARCHIVE_AFTER = 2.weeks

  belongs_to :recipient, class_name: 'User'

  validates :recipient_id, presence: true
  validates :first_sender_name, presence: true
  validates :last_sender_name, presence: true
  validates :sender_email, presence: true, email: true
  validates :body, presence: true
  validates :fingerprint, presence: true, uniqueness: true, strict: true

  before_validation :generate_fingerprint, on: :create, unless: :fingerprint?
  after_create :send_notification_email

  default_scope -> { order(:created_at).reverse_order }
  # scope :archived, -> { read.where(arel_table[:created_at].lt(ARCHIVE_AFTER.ago)) }
  # scope :incoming, -> { where(unread.where_values.reduce(:and).or(arel_table[:created_at].gteq(ARCHIVE_AFTER.ago))) }
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
    def broadcast(recipients, attributes = {})
      fingerprint = generate_fingerprint
      transaction do
        Array(recipients).each do |recipient|
          create!(attributes.merge(recipient: recipient, fingerprint: fingerprint))
        end
      end
    end

    def generate_fingerprint
      SecureRandom.uuid
    end

    def without(message)
      if message.new_record?
        all
      else
        where.not(id: message.id)
      end
    end
  end

  # def archived?
  #  read? and created_at < ARCHIVE_AFTER.ago
  # end

  def copies
    @copies ||= self.class.where(fingerprint: fingerprint).without(self).readonly
  end

  def copy_ids
    @copy_ids ||= (copies.loaded? ? copies.collect(&:id) : copies.pluck(:id)).freeze
  end

  def full_sender_name
    "#{first_sender_name} #{last_sender_name}".strip
  end
  alias_method :sender_name, :full_sender_name

  def generate_fingerprint
    self.fingerprint = self.class.generate_fingerprint
  end

  # def incoming?
  #   !archived?
  # end

  def mark_read!
    update_column(:read, true)
  end

  def mark_unread!
    update_column(:read, false)
  end

  def other_recipients
    @other_recipients ||= User.where(id: other_recipient_ids).readonly
  end

  def other_recipient_ids
    @other_recipient_ids ||= recipient_ids - [self.id]
  end

  def recipients
    @recipients ||= User.where(id: recipient_ids).readonly
  end

  def recipient_ids
    @recipient_ids ||= self.class.where(fingerprint: fingerprint).pluck(:recipient_id).freeze
  end

  def unread?
    !read?
  end

  private
  def send_notification_email
    # TODO
  end
end
