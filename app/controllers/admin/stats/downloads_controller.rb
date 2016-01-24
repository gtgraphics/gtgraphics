module Admin
  module Stats
    class DownloadsController < Admin::Stats::ApplicationController
      PAGE_SIZE = 25

      before_action :set_year, only: %i(year month)
      before_action :set_month, only: :month
      before_action :set_type, only: %i(total year month)
      before_action :load_downloads
      before_action :load_referers, only: %i(index referers)

      breadcrumbs do |b|
        b.append translate('views.admin.stats.downloads'),
                 :admin_stats_downloads
        if action_name == 'total'
          b.append 'Gesamt', :admin_stats_total_downloads
        end
        if action_name == 'referers'
          b.append 'Referenzierende Seiten', :admin_stats_download_referers
        end
        if @year
          b.append @year, admin_stats_yearly_downloads_path(year: @year)
          if @month
            b.append translate('date.month_names')[@month],
                     admin_stats_monthly_downloads_path(year: @year, month: @month)
          end
        end
      end

      def index
        @bytes_total = calculate_sum(:file_size)
        @bytes_sent = calculate_sum('downloads_count * file_size::bigint')
        @referers = @referers.limit(PAGE_SIZE)

        respond_to :html
      end

      def referers
        @referers = @referers.page(params[:page]).per(PAGE_SIZE)

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
          .joins(
            <<-SQL.strip_heredoc
              INNER JOIN hits
              ON hits.type = 'Download'
              AND hits.hittable_id = image_styles.id
              AND hits.hittable_type = 'Image::Style'
            SQL
          )
          .group('images.id').select('images.*')
          .select('COUNT(hits.id) AS count')
          .select('MAX(hits.created_at) AS last_downloaded_at')
          .order('COUNT(hits.id) DESC')
        )
        @downloads_count = filter_by_time(Download.image_styles).count
      end

      def load_generic_downloads
        partition = 'OVER (PARTITION BY hittable_type, hittable_id)'
        @downloads = filter_by_time(
          Download.uniq.select(:hittable_id, :hittable_type)
          .select("COUNT(id) #{partition} AS count")
          .select("MAX(created_at) #{partition} AS last_downloaded_at")
          .order('count DESC').preload(hittable: :translations)
          .public_send(@type || 'all')
        )
      end

      def load_referers
        excluded_url = Rails.env.in?(%w(development test)) ? 'localhost' : 'gtgraphics.de'
        @referers = Download.group(:referer).order('count_all DESC')
                    .where('referer IS NULL OR referer NOT ILIKE ?',
                           "%#{excluded_url}%")
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
        default_args = [1, 0, 0, 0, DateTime.now.offset]
        if @month
          begins_at = DateTime.new(@year, @month, *default_args)
          ends_at = begins_at.end_of_month
        elsif @year
          begins_at = DateTime.new(@year, 1, *default_args)
          ends_at = begins_at.end_of_year
        end
        return scope if begins_at.nil? || ends_at.nil?
        scope.where(downloads: { created_at: begins_at..ends_at })
      end
    end
  end
end
