module Hittable
  extend ActiveSupport::Concern

  included do
    class_attribute :hittable_name

    has_many :hits, as: :hittable, dependent: :delete_all
  end

  module ClassMethods
    ##
    # @return [Class]
    def hittable_class
      if hittable_name.blank?
        fail "Use the track_hits_as macro to define a hit type on #{name}"
      end
      hittable_name.classify.constantize
    end

    ##
    # A macro that is used to initialize trackability on the model.
    #
    # @param [Symbol] The hit type. May be either :visit or :download.
    def track_hits_as(name)
      self.hittable_name = name.to_s

      define_method(:"track_#{hittable_name}!") do |*args|
        track_hit!(*args)
      end
    end
  end

  ##
  # Track a single {Hit} for the current resource.
  #
  # @param [ActionDispatch::Request] request The request that is used to
  #   store additional information on the {Hit}.
  # @return [Hit]
  def track_hit!(request = nil)
    self.class.hittable_class.create!(hittable: self) do |download|
      if request
        download.ip = request.ip
        download.referer = request.referer
        download.user_agent = request.user_agent
      end
    end
  end
end
