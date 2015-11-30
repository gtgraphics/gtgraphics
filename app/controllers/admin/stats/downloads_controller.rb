module Admin
  module Stats
    class DownloadsController < Admin::Stats::ApplicationController
      PAGE_SIZE = 40

      before_action :set_year, only: %i(year month)
      before_action :set_month, only: :month
      before_action :set_type, only: %i(total year month)
      before_action :load_downloads

      breadcrumbs do |b|
        b.append translate('views.admin.stats.downloads'),
                 :admin_stats_downloads
        if action_name == 'total'
          b.append 'Gesamt', :admin_stats_total_downloads
        end
        if @year
          b.append @year, admin_stats_yearly_downloads_path(year: @year)
          b.append translate('date.month_names')[@month], admin_stats_monthly_downloads_path(year: @year, month: @month) if @month
        end
      end

      def index
        @bytes_total = calculate_sum(:file_size)
        @bytes_sent = calculate_sum('downloads_count * file_size')

        respond_to :html
      end

      def total
        @downloads = @downloads.page(params[:page]).per(PAGE_SIZE)

        respond_to do |format|
          format.html { render :timespan }
        end
      end

      def year
        @downloads = @downloads.page(params[:page]).per(PAGE_SIZE)

        respond_to do |format|
          format.html { render :timespan }
        end
      end

      def month
        @downloads = @downloads.page(params[:page]).per(PAGE_SIZE)

        respond_to do |format|
          format.html { render :timespan }
        end
      end

      private

      def load_downloads
        if @type == 'images'
          @downloads = ::Image.joins(:styles)
                       .group('images.id')
                       .select('images.*')
                       .select('SUM(image_styles.downloads_count) AS count')
                       .order('SUM(image_styles.downloads_count) DESC')
          @downloads_count = Download.image_styles.count
        else
          partition = 'OVER (PARTITION BY downloadable_type, downloadable_id)'
          @downloads =
            Download.uniq.select(:downloadable_id, :downloadable_type)
            .select("COUNT(id) #{partition} AS count")
            .select("MAX(created_at) #{partition} AS last_downloaded_at")
            .order('count DESC').preload(downloadable: :translations)
            .public_send(@type || 'all')
        end
      end

      def calculate_sum(aggregation)
        [Attachment, ::Image::Style]
          .collect { |model| model.sum(aggregation) }.sum
      end

      def set_type
        @type = params[:type].presence_in(%w(images image_styles attachments))
      end

      def set_year
        @year = params[:year].to_i
      end

      def set_month
        @month = params[:month].to_i
      end
    end
  end
end
