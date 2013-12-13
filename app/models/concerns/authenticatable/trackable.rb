module Authenticatable::Trackable
  extend ActiveSupport::Concern

  included do

  end

  module ClassMethods
    def active_within(time)
      where(last_activity_at: time.ago..DateTime.now)
    end
  end

end