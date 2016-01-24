module Admin
  class DownloadPresenter < Admin::ApplicationPresenter
    include FileAttachablePresenter

    presents :download

    def downloadable
      @downloadable ||= present [:admin, download.hittable] unless image?
    end

    def title
      downloadable.try(:title) || download.try(:title)
    end

    def subtitle
      if image?
        "#{image.styles.size} #{::Image::Style.model_name.human(count: image.styles.size)}"
      elsif download.attachment?
        content_type
      else
        image.title
      end
    end

    def thumbnail
      html_options = { class: 'img-circle', alt: title, width: 45, height: 45 }
      if download.is_a?(::Image)
        h.link_to show_path, target: '_blank' do
          h.image_tag h.attached_asset_path(image, :thumbnail), html_options
        end
      else
        return nil unless download.image_style?
        h.link_to show_path, target: '_blank' do
          h.image_tag h.attached_asset_path(downloadable, :thumbnail), html_options
        end
      end
    end

    def count
      return nil unless download.respond_to?(:count)
      h.number_with_delimiter(download.count)
    end

    def last_downloaded_at
      return nil if download.try(:last_downloaded_at).nil?
      I18n.localize(super.in_time_zone, format: :short)
    end

    def show_path
      return h.admin_image_path(image) if image?
      return downloadable.show_path if download.attachment?
      h.admin_image_path(image)
    end

    def download_path
      fail 'No download path available for image' if image?
      downloadable.download_path
    end

    def image?
      download.is_a?(::Image)
    end

    private

    def image
      return download if image?
      downloadable.image
    end
  end
end
