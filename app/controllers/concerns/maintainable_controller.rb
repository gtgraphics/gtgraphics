module MaintainableController
  extend ActiveSupport::Concern

  class Maintained < StandardError
  end

  MAINTENANCE_FILE = Rails.root.join('public', 'system', '.maintenance')

  included do
    #unless Rails.application.config.consider_all_requests_local
      before_action :check_for_maintenance
      rescue_from(Maintained) { render_error :service_unavailable }
    #end
  end

  module ClassMethods
    protected
    def skip_maintenance_check
      skip_before_action :check_for_maintenance
    end
  end

  private
  def check_for_maintenance
    raise Maintained if signed_out? and File.exists?(MAINTENANCE_FILE)
  end
end