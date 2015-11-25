module Admin
  module TrafficHelper
    def monthly_traffic_chart(traffic)
      data = MonthChart.data(traffic)
      lib_options = { 'hAxis' => { 'format' => 'MMMM', 'gridlines' => { 'count' => -1 } } }
      area_chart(data, xtitle: 'Monat', ytitle: 'MB', library: lib_options)
    end

    def daily_traffic_chart(traffic)
      data = DailyChart.data(traffic)
      lib_options = { 'hAxis' => { 'format' => 'dd.MM', 'gridlines' => { 'count' => -1 } } }
      area_chart(data, xtitle: 'Datum', ytitle: 'MB', library: lib_options)
    end

    def hourly_traffic_chart(traffic)
      data = HourlyChart.data(traffic)
      lib_options = { 'hAxis' => { 'format' => 'HH', 'gridlines' => { 'count' => 24 } } }
      area_chart(data, xtitle: 'Stunde', ytitle: 'MB', library: lib_options)
    end

    class Chart
      attr_reader :traffic

      def initialize(traffic)
        @traffic = traffic
      end

      def self.data(*args)
        new(*args).data
      end

      def data
        data = []
        data << { name: 'Empfangen', data: data_for(:bytes_received) }
        data << { name: 'Gesendet', data: data_for(:bytes_sent) }
        data
      end

      private

      def bytes_to_mbs(bytes)
        bytes.to_i / (1024 ** 2)
      end
    end

    class MonthChart < Chart
      private

      def data_for(type)
        traffic.each_with_object({}) do |result, hash|
          value = bytes_to_mbs(result.public_send(type))
          hash[Date.new(result.year, result.month)] = value
        end
      end
    end

    class DailyChart < Chart
      private

      def data_for(type)
        traffic.each_with_object({}) do |result, hash|
          hash[result.date] = bytes_to_mbs(result.public_send(type))
        end
      end
    end

    class HourlyChart < Chart
      private

      def data_for(type)
        traffic.each_with_object({}) do |result, hash|
          hash[result.time] = bytes_to_mbs(result.public_send(type))
        end
      end
    end
  end
end
