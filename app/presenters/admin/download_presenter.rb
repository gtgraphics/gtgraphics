module Admin
  class DownloadPresenter < Admin::ApplicationPresenter
    include FileAttachablePresenter

    presents :download

    def downloadable
      @downloadable ||= present [:admin, super]
    end

    delegate :title, :show_path, :download_path, to: :downloadable

    def subtitle
      return content_type if download.attachment?
      downloadable.image.title
    end

    def count
      h.number_with_delimiter(super)
    end

    def last_downloaded_at
      return nil if download.try(:last_downloaded_at).nil?
      I18n.localize(super.in_time_zone, format: :short)
    end

    def thumbnail
      return nil unless download.image_style?
      h.link_to show_path, target: '_blank' do
        h.image_tag h.attached_asset_path(downloadable, :thumbnail), class: 'img-circle', alt: title, width: 45, height: 45
      end
    end

    def show_path
      return downloadable.show_path if download.attachment?
      h.admin_image_path(downloadable.image)
    end
  end
end
