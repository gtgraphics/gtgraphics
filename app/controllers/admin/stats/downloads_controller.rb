module Admin
  module Stats
    class DownloadsController < Admin::Stats::ApplicationController
      PAGE_SIZE = 25

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
          load_image_downloads
        else
          load_generic_downloads
        end
      end

      def load_image_downloads
        @downloads = filter_by_time(
          ::Image.joins(:styles)
          .joins(%{
            INNER JOIN downloads
            ON downloads.downloadable_id = image_styles.id
            AND downloads.downloadable_type = 'Image::Style'
          })
          .group('images.id').select('images.*')
          .select('COUNT(downloads.id) AS count')
          .select('MAX(downloads.created_at) AS last_downloaded_at')
          .order('COUNT(downloads.id) DESC')
        )
        @downloads_count = filter_by_time(Download.image_styles).count
      end

      def load_generic_downloads
        partition = 'OVER (PARTITION BY downloadable_type, downloadable_id)'
        @downloads = filter_by_time(
          Download.uniq.select(:downloadable_id, :downloadable_type)
          .select("COUNT(id) #{partition} AS count")
          .select("MAX(created_at) #{partition} AS last_downloaded_at")
          .order('count DESC').preload(downloadable: :translations)
          .public_send(@type || 'all')
        )
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

      def filter_by_time(scope)
        begins_at = DateTime.new(@year, @month, 1, 0, 0, 0, DateTime.now.offset)
        if @month
          ends_at = begins_at.end_of_month
        elsif @year
          ends_at = begins_at.end_of_year
        end
        return scope if begins_at.nil? || ends_at.nil?
        scope.where(downloads: { created_at: begins_at..ends_at })
      end
    end
  end
end
