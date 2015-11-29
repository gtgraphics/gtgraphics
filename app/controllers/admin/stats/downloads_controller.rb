module Admin
  module Stats
    class DownloadsController < Admin::Stats::ApplicationController
      PAGE_SIZE = 40

      breadcrumbs do |b|
        b.append translate('views.admin.stats.downloads'),
                 :admin_stats_downloads
      end

      def index
        @bytes_total = calculate_sum(:file_size)
        @bytes_sent = calculate_sum('downloads_count * file_size')

        partition = 'OVER (PARTITION BY downloadable_type, downloadable_id)'
        @downloads = Download.all
        @grouped_downloads =
          Download.uniq.select(:downloadable_id, :downloadable_type)
          .select("COUNT(id) #{partition} AS count")
          .select("MAX(created_at) #{partition} AS last_downloaded_at")
          .order('count DESC').preload(downloadable: :translations)

        respond_to :html
      end

      private

      def calculate_sum(aggregation)
        [Attachment, ::Image::Style]
          .collect { |model| model.sum(aggregation) }.sum
      end
    end
  end
end
