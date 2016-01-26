module Admin
  module Stats
    class VisitsController < Admin::Stats::ApplicationController
      include Admin::Stats::TimeFilterableController

      def index
        respond_to :html
      end

      def year
        respond_to do |format|
          format.html
        end
      end

      def month
        respond_to do |format|
          format.html
        end
      end
    end
  end
end
