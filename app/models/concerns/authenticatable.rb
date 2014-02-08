module Authenticatable
  extend ActiveSupport::Concern

  included do
    has_secure_password

    delegate :checksum, :salt, to: :password_hash, prefix: :password

    class << self
      alias_method :signed_in?, :authenticated?
      alias_method :signed_out?, :anonymous?
    end

    alias_method :current_user?, :current?
  end

  module ClassMethods
    def anonymous?
      current.nil?
    end

    def authenticated?
      !current.nil?
    end

    def current
      Thread.current[:"current_#{self.name.underscore}"]
    end

    def generate_password
      PasswordGenerator.generate
    end
  end

  def current?
    self == self.class.current
  end

  def password_hash
    BCrypt::Password.new(password_digest)
  end

  private
  def set_generated_password
    self.password = self.password_confirmation = self.class.generate_password
  end
end