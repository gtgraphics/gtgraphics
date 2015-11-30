class Image < ActiveRecord::Base
  class AttachmentPresenter < ApplicationPresenter
    include FileAttachablePresenter

    presents :attachment

    def title
      super.presence || filename
    end

    def filename
      attachment.asset.filename
    end

    def url
      h.download_attachment_path(filename: filename, locale: nil)
    end
  end
end
