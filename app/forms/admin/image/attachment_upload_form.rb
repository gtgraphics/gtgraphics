module Admin
  module Image
    class AttachmentUploadForm < BaseForm
      attr_accessor :asset

      validates :asset, presence: true

      def perform
        ::Image::Download.transaction do
          attachment = Attachment.create!(asset: asset)
          download = image.downloads.create!(attachment: attachment)
          recalculate_position!(download)
          downloads << download
        end
      end
    end
  end
end
