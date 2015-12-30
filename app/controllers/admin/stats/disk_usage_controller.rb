module Admin
  module Stats
    class DiskUsageController < Admin::Stats::ApplicationController
      def index
        file_system = Sys::Filesystem.stat('/')

        @bytes_total = file_system.bytes_total
        @bytes_used = file_system.bytes_used
        @bytes_free = file_system.bytes_free

        @quote_used = @bytes_used * 100 / @bytes_total.to_f
        @quote_free = @bytes_free * 100 / @bytes_total.to_f

        respond_to :html
      end
    end
  end
end
