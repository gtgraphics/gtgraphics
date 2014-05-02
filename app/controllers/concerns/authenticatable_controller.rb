module AuthenticatableController
  extend ActiveSupport::Concern

  SESSION_KEY = :authenticated_user

  module SessionSerializer
    class << self
      def dump(user)
        [user.id, user.password_salt]
      end

      def parse(dump)
        return nil unless dump.is_a?(Array) and dump.length == 2
        user_id, password_salt = dump
        user = User.find_by(id: user_id)
        user if user and user.password_salt == password_salt
      end
    end
  end

  included do
    helper_method :current_user, :signed_in?, :signed_out?, :anonymous?, :authenticated?

    before_action :set_current_user
    before_action :track_last_user_activity

    alias_method :anonymous?, :signed_out?
    alias_method :authenticated?, :signed_in?
  end

  module ClassMethods
    def authenticate(options = {})
      before_action :authenticate!, options
    end

    def skip_authentication(options = {})
      skip_before_action :authenticate!, options
    end
  end

  protected
  def authenticate!
    raise Authenticatable::AccessDenied if signed_out?
  end

  def current_user
    @current_user ||= SessionSerializer.parse(session[SESSION_KEY])
    @current_user ||= SessionSerializer.parse(cookies.signed[SESSION_KEY])
  end
  
  def sign_in(user, options = {})
    options.reverse_merge!(permanent: false)
    if options[:permanent]
      cookies.permanent.signed[SESSION_KEY] = SessionSerializer.dump(user)
      session[SESSION_KEY] = nil
    else
      session[SESSION_KEY] = SessionSerializer.dump(user)
      cookies.delete(SESSION_KEY)
    end
    @current_user = user
  end

  def signed_in?
    !signed_out?
  end
  
  def sign_out
    session[SESSION_KEY] = nil
    cookies.delete(SESSION_KEY)
    @current_user = nil
  end

  def signed_out?
    current_user.nil?
  end

  private
  def set_current_user
    Thread.current[:current_user] = current_user
  end

  def track_last_user_activity
    current_user.try(:track_activity!, request.ip)
  end
end