# == Schema Information
#
# Table name: messages
#
#  id           :integer          not null, primary key
#  recipient_id :integer
#  first_name   :string(255)
#  last_name    :string(255)
#  email        :string(255)
#  subject      :string(255)
#  body         :text
#  created_at   :datetime
#

class Message < ActiveRecord::Base
  belongs_to :recipient, class_name: 'User'

  validates :recipient_id, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, email: true
  validates :body, presence: true

  after_create :send_notification_email

  default_scope -> { order(:created_at).reverse_order }

  private
  def send_notification_email
    # TODO
  end
end
