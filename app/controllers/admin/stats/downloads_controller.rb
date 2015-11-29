module Admin
  module Stats
    class DownloadsController < Admin::Stats::ApplicationController
      PAGE_SIZE = 40

      before_action :load_attachments, only: %i(index attachments)
      before_action :load_images, only: %i(index images)
      before_action :load_image_styles, only: %i(index image_styles)

      breadcrumbs do |b|
        b.append translate('views.admin.stats.downloads'),
                 :admin_stats_downloads
      end

      def index
        @downloads_count = calculate_sum(:downloads_count)
        @bytes_total = calculate_sum(:file_size)
        @bytes_sent = calculate_sum('downloads_count * file_size')

        @attachments = @attachments.limit(10)
        @images = @images.limit(10)
        @image_styles = @image_styles.limit(10)

        respond_to :html
      end

      def image_styles
        breadcrumbs.append ::Image::Style.model_name.human(count: 2),
                           :admin_stats_downloaded_image_styles

        @image_styles = @image_styles.page(params[:page]).per(PAGE_SIZE)

        respond_to :html
      end

      def images
        breadcrumbs.append ::Image.model_name.human(count: 2),
                           :admin_stats_downloaded_images

        @images = @images.page(params[:page]).per(PAGE_SIZE)

        respond_to :html
      end

      def attachments
        breadcrumbs.append Attachment.model_name.human(count: 2),
                           :admin_stats_downloaded_attachments

        @attachments = @attachments.page(params[:page]).per(PAGE_SIZE)

        respond_to :html
      end

      private

      def load_attachments
        @attachments = Attachment.where('downloads_count > 0')
                       .reorder(:downloads_count).reverse_order
      end

      def load_image_styles
        @image_styles = ::Image::Style.where('downloads_count > 0')
                        .reorder(:downloads_count).reverse_order
                        .preload(:image)
      end

      def load_images
        @images = ::Image.joins(:styles).where('downloads_count > 1')
                  .group('images.id').select('images.*')
                  .select('SUM(image_styles.downloads_count) AS downloads_count')
                  .order('SUM(image_styles.downloads_count) DESC')
                  .preload(:styles)
      end

      def calculate_sum(aggregation)
        [Attachment, ::Image::Style]
          .collect { |model| model.sum(aggregation) }.sum
      end
    end
  end
end
