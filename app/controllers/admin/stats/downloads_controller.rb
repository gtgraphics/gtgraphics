module Admin
  module Stats
    class DownloadsController < Admin::Stats::ApplicationController
      breadcrumbs do |b|
        b.append translate('views.admin.stats/downloads'), :admin_stats_downloads
      end

      def index
        # @images = ::Image.all

        respond_to :html
      end
    end
  end
end
