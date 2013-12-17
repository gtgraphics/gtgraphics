module Authenticatable::Trackable
  extend ActiveSupport::Concern

  module ClassMethods
    def active_within(time)
      where(last_activity_at: time.ago..DateTime.now)
    end
  end

  def active_within?(time)
    return nil if last_activity_at.nil?
    last_activity_at >= time.ago
  end

  # Last Activity

  def track_activity(ip)
    update(_track_activity_attributes(ip))
  end

  def track_activity!(ip)
    update!(_track_activity_attributes(ip))
  end

  # Current Sign In

  def track_sign_in(ip)
    update(_track_sign_in_attributes(ip))
  end

  def track_sign_in!(ip)
    update!(_track_sign_in_attributes(ip))
  end

  private
  def _track_activity_attributes(ip)
    {
      last_activity_at: DateTime.now,
      last_activity_ip: ip
    }
  end

  def _track_sign_in_attributes(ip)
    {
      current_sign_in_at: DateTime.now,
      current_sign_in_ip: ip,
      sign_in_count: sign_in_count + 1,
      last_sign_in_at: current_sign_in_at,
      last_sign_in_ip: current_sign_in_ip
    }
  end
end