module Authenticatable
  extend ActiveSupport::Concern

  GENERATED_PASSWORD_LENGTH = 10..12

  included do
    authenticates_with_sorcery!

    alias_method :me?, :current?
  end

  module ClassMethods
    def logged_out?
      current.nil?
    end

    def logged_in?
      !current.nil?
    end

    def current
      Thread.current[thread_store_key]
    end

    def current=(user)
      Thread.current[thread_store_key] = user
    end

    def generate_password
      RandomString.generate(GENERATED_PASSWORD_LENGTH)
    end

    private

    def thread_store_key
      "authentications.#{self.name.underscore.pluralize}.current"
    end
  end

  def current?
    self == self.class.current
  end

  def recently_active?
    self.class.current_users.include?(self)
  end
end
