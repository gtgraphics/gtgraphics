module Admin
  module Stats
    class TrafficController < Admin::Stats::ApplicationController
      breadcrumbs do |b|
        b.append translate('views.admin.stats.traffic'),
                 :admin_stats_traffic
      end

      def index
        begin
          @interface = Vnstat.interfaces.first
          if @interface
            @total_traffic = @interface.total
            @monthly_traffic = @interface.months.sort.reverse
            @daily_traffic = @interface.days.sort.reverse
            @hourly_traffic = @interface.hours.sort.reverse
            @top_traffic = @interface.tops.sort_by(&:bytes_transmitted).reverse

            @monthly_traffic_used = @interface.months[Date.today.year, Date.today.month].bytes_transmitted
            @monthly_traffic_max = 1000 * (1024 ** 3)
          else
            @error_message = 'Keine Netzwerkschnittstelle gefunden.'
          end
        rescue Vnstat::Error => error
          @error_message = error.message
        end

        respond_to :html
      end

      def reset
        begin
          interface = Vnstat.interfaces.first
          interface.reset

          respond_to do |format|
            format.html { redirect_to :admin_stats_traffic }
          end
        rescue Vnstat::Error
          respond_to do |format|
            format.html do
              redirect_to :back, alert: 'Konnte Statistik nicht zurücksetzen.'
            end
          end
        end
      end
    end
  end
end
