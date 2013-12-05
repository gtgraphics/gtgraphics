class Message
  include ActiveModel::Model

  attr_accessor :first_name, :last_name, :email, :subject, :body

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, email: true
  validates :body, presence: true

  class << self
    def create(attributes = {})
      new(attributes).tap(&:save)
    end
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def recipient
    if full_name.present?
      %{"#{full_name}" <#{email}>}
    else
      email
    end
  end

  def save
    if valid?
      job = MessageMailerJob.new(self)
      Delayed::Job.enqueue(job)
      true
    else
      false
    end
  end
end