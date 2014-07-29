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
  include Excludable
  include PersistenceContextTrackable
  
  # belongs_to :contact_form, class_name: 'Page::ContactForm'
  has_many :recipiences, class_name: 'Message::Recipience', autosave: true, dependent: :destroy, inverse_of: :message
  has_many :recipients, through: :recipiences

  validates :first_sender_name, presence: true
  validates :last_sender_name, presence: true
  validates :sender_email, presence: true, email: true

  before_create :build_recipiences

  def sender
    %{"#{sender_name}" <#{sender_email}>}
  end

  def sender_name
    "#{first_sender_name} #{last_sender_name}".strip
  end

  protected
  def build_recipiences
    # overridden in subclasses
  end
end
