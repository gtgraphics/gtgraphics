module Admin
  module Stats
    class DiskUsageController < Admin::Stats::ApplicationController
      def index
        file_system = Sys::Filesystem.stat('/')

        @bytes_total = file_system.bytes_total
        @bytes_used = file_system.bytes_used
        @bytes_free = file_system.bytes_free

        respond_to :html
      end
    end
  end
end
