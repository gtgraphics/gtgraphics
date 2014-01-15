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
  belongs_to :contact_form, class_name: 'Page::ContactForm'
  has_many :recipiences, class_name: 'Message::Recipience', dependent: :destroy, inverse_of: :message
  has_many :recipients, through: :recipiences, source: :recipient

  validates :contact_form_id, presence: true, on: :create
  validates :first_sender_name, presence: true
  validates :last_sender_name, presence: true
  validates :sender_email, presence: true, email: true
  validates :body, presence: true

  after_create :create_recipiences

  delegate :name, to: :recipient, prefix: true
  alias_method :full_recipient_name, :recipient_name

  class << self
    def without(message)
      if message.new_record?
        all
      else
        where.not(id: message.id)
      end
    end
  end

  def full_sender_name
    "#{first_sender_name} #{last_sender_name}".strip
  end
  alias_method :sender_name, :full_sender_name

  def sender
    %{"#{full_sender_name}" <#{sender_email}>}
  end

  private
  def create_recipiences
    # TODO
  end
end
