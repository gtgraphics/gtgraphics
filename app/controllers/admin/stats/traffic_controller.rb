module Admin
  module Stats
    class TrafficController < Admin::Stats::ApplicationController
      before_action :load_interface

      breadcrumbs do |b|
        b.append translate('views.admin.stats/traffic'), :admin_stats_traffic
      end

      def index
        @total_traffic = @interface.total
        @monthly_traffic = @interface.months.sort.reverse
        @daily_traffic = @interface.days.sort.reverse
        @hourly_traffic = @interface.hours.sort.reverse

        respond_to :html
      end

      def reset
        @interface.reset

        respond_to do |format|
          format.html { redirect_to :admin_stats_traffic }
        end
      end

      private

      def load_interface
        @interface = Vnstat.interfaces.first
      end
    end
  end
end
