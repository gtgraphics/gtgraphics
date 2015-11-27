class Image < ActiveRecord::Base
  class DownloadPresenter < ApplicationPresenter
    include FileAttachablePresenter

    presents :download

    def title
      super.presence || filename
    end

    def filename
      download.asset.filename
    end

    def url
      h.download_attachment_path(filename: filename, locale: nil)
    end
  end
end
