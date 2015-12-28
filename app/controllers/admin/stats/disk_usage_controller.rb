module Admin
  module Stats
    class DiskUsageController < ApplicationController
      def index
        file_system = Sys::Filesystem.stat('/')
        @bytes_total = file_system.bytes_total
        @bytes_used = file_system.bytes_used

        respond_to :html
      end
    end
  end
end
