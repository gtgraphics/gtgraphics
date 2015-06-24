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
  include Excludable
  include PersistenceContextTrackable

  has_many :recipiences, class_name: 'Message::Recipience', autosave: true,
                         dependent: :destroy, inverse_of: :message
  has_many :recipients, through: :recipiences

  validates :first_sender_name, presence: true
  validates :last_sender_name, presence: true
  validates :sender_email, presence: true, email: true
  validates :ip, presence: true, strict: true, on: :create

  with_options if: :suspicious? do |opts|
    opts.validates :security_answer,
                   presence: true,
                   numericality: { only_integer: true, allow_blank: true }
    opts.validate :verify_security_answer
  end

  before_validation :sanitize_attributes, on: :create
  before_create :build_recipiences
  after_create :create_sender_info

  def sender
    %("#{sender_name}" <#{sender_email}>)
  end

  def sender_name
    "#{first_sender_name} #{last_sender_name}".strip
  end

  def suspicious?
    unless defined?(@suspicious)
      @suspicious =
        Message::SenderInfo.recent?(ip) ||
        (sender_name.present? && first_sender_name == last_sender_name)
    end
    @suspicious
  end

  attr_accessor :security_question, :security_answer

  def notify!
    fail 'Message#notify! requires the message to be saved' unless persisted?
    MessageNotificationMailer.notification_email(self).deliver_now
  end

  protected

  def build_recipiences
    # overridden in subclasses
  end

  def sanitize_attributes
    %w(first_sender_name last_sender_name sender_email
       subject body).each do |attribute|
      value = public_send(attribute)
      if value.respond_to?(:valid_encoding?) && !value.valid_encoding?
        value = value.encode(Encoding::UTF_8, Encoding::BINARY,
                             invalid: :replace, undef: :replace, replace: '')
      end
      public_send("#{attribute}=", value.try(:strip))
    end
  end

  def verify_security_answer
    return true if security_question.valid?(security_answer)
    errors.add(:security_answer, :invalid)
  end

  def create_sender_info
    Message::SenderInfo.create!(ip: ip)
  end
end
