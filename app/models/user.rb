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
  require 'user/messaging'

  include Authenticatable
  include Authenticatable::Lockable
  include Authenticatable::Trackable
  include Authorizable
  include Excludable
  include PersistenceContextTrackable
  include Sortable
  include User::Messaging

  store :preferences

  with_options foreign_key: :author_id, dependent: :nullify do |author|
    author.has_many :attachments
    author.has_many :images
    author.has_many :pages
    author.has_many :snippets
  end

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, email: true
  validates :preferred_locale, inclusion: { in: -> { I18n.available_locales.map(&:to_s) } }, allow_blank: true

  before_validation :sanitize_preferred_locale
  before_validation :set_generated_password, if: :generate_password?

  default_scope -> { order(:first_name, :last_name) }

  acts_as_sortable do |by|
    by.full_name(default: true) { |dir| [arel_table[:first_name].send(dir.to_sym), arel_table[:last_name].send(dir.to_sym)] }
  end

  def self.search(query)
    if query.present?
      terms = query.split
      columns = [:first_name, :last_name]
      conditions = terms.collect do |term|
        columns.collect { |column_name| arel_table[column_name].matches("%#{term}%") }.reduce(:or)
      end
      where(conditions.reduce(:and))
    else
      all
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
    @generate_password = generate_password.to_b
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

  def to_param
    "#{id}-#{name.parameterize}"
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
