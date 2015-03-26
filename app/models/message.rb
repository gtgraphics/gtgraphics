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

  SPAM_THRESHOLD = 1.day

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

  before_create :build_recipiences

  before_validation :sanitize_attributes, on: :create

  def sender
    %("#{sender_name}" <#{sender_email}>)
  end

  def sender_name
    "#{first_sender_name} #{last_sender_name}".strip
  end

  def suspicious?
    unless defined?(@suspicious)
      @suspicious =
        recently_sent_from_same_ip? ||
        (sender_name.present? && first_sender_name == last_sender_name)
    end
    @suspicious
  end

  def recently_sent_from_same_ip?
    Message.where(ip: ip).where('created_at > ?', SPAM_THRESHOLD.ago).exists?
  end

  attr_accessor :security_question, :security_answer

  def notify!
    unless persisted?
      fail 'Message#notify! requires the message to be persisted'
    end
    notifier_job = MessageNotificationJob.new(id, I18n.locale)
    Delayed::Job.enqueue(notifier_job, queue: 'mailings')
  end

  protected

  def build_recipiences
    # overridden in subclasses
  end

  def sanitize_attributes
    %w(first_sender_name last_sender_name sender_email
       subject body).each do |attribute|
      public_send("#{attribute}=", public_send(attribute).try(:strip))
    end
  end

  def verify_security_answer
    return true if security_question.valid?(security_answer)
    errors.add(:security_answer, :invalid)
  end
end
