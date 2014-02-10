# == Schema Information
#
# Table name: users
#
#  id                      :integer          not null, primary key
#  first_name              :string(255)
#  last_name               :string(255)
#  preferred_locale        :string(255)
#  email                   :string(255)      not null
#  password_digest         :string(255)      not null
#  created_at              :datetime
#  updated_at              :datetime
#  lock_state              :string(255)      not null
#  locked_until            :datetime
#  failed_sign_in_attempts :integer          default(0), not null
#  last_activity_at        :datetime
#  last_activity_ip        :string(255)
#  sign_in_count           :integer          default(0), not null
#  current_sign_in_at      :datetime
#  current_sign_in_ip      :string(255)
#  last_sign_in_at         :datetime
#  last_sign_in_ip         :string(255)
#  preferences             :text
#

class User < ActiveRecord::Base
  include Authenticatable
  include Authenticatable::Lockable
  include Authenticatable::Trackable
  include PersistenceContextTrackable
  include Sortable

  store :preferences

  with_options foreign_key: :author_id, dependent: :nullify do |author|
    author.has_many :attachments
    author.has_many :images
    author.has_many :pages
    author.has_many :snippets
  end
  has_many :message_recipiences, class_name: 'Message::Recipience', foreign_key: :recipient_id, dependent: :destroy
  has_many :messages, -> { readonly }, through: :message_recipiences
  has_and_belongs_to_many :addressed_contact_forms, class_name: 'Page::ContactForm', join_table: 'contact_form_recipients', foreign_key: :recipient_id, association_foreign_key: :contact_form_page_id

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true

  before_validation :sanitize_preferred_locale
  before_validation :set_generated_password, if: :generate_password?

  default_scope -> { order(:first_name, :last_name) }

  acts_as_sortable do |by|
    by.full_name(default: true) { |dir| [arel_table[:first_name].send(dir.to_sym), arel_table[:last_name].send(dir.to_sym)] }
  end

  class << self
    def without(user)
      if user.new_record?
        all
      else
        where.not(id: user.id)
      end
    end
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end
  alias_method :name, :full_name

  def generate_password?
    @generate_password = false unless defined? @generate_password
    @generate_password
  end
  alias_method :generate_password, :generate_password?

  def generate_password=(generate_password)
    @generate_password = generate_password.in?(ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES)
  end

  def mail_formatted_name
    if full_name.present?
      %{"#{full_name}" <#{email}>}
    else
      email
    end
  end

  def password_changed?
    new_record? or password.present?
  end

  def preferred_locale_name
    I18n.translate(preferred_locale, scope: :languages) if preferred_locale.present?
  end

  def to_liquid
    attributes.slice(*%w(first_name last_name email)).merge(
      'name' => full_name,
      'full_name' => full_name
    )
  end

  def to_s
    full_name
  end

  private
  def sanitize_preferred_locale
    self.preferred_locale = preferred_locale.to_s.downcase.presence
  end

  def set_generated_password
    self.password = self.password_confirmation = self.class.generate_password
  end
end
