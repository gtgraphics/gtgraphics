module MaintainableController
  extend ActiveSupport::Concern

  class Maintained < Exception
  end

  MAINTENANCE_FILE = Rails.root.join('public', 'system', '.maintenance')

  included do
    before_action :check_for_maintenance
    rescue_from Maintained, with: :render_503
  end

  private
  def check_for_maintenance
    raise Maintained if !user_signed_in? and File.exists?(MAINTENANCE_FILE)
  end

  def render_503
    respond_to do |format|
      format.html { render 'public/503', layout: false, status: :service_unavailable }
      format.all { head :service_unavailable }
    end
  end
end