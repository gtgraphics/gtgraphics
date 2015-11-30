module Admin
  module Image
    class AttachmentUploadForm < BaseForm
      attr_accessor :asset

      validates :asset, presence: true

      def perform
        ::Image::Attachment.transaction do
          attachment = Attachment.create!(asset: asset)
          image_attachment =
            image.image_attachments.create!(attachment: attachment)
          recalculate_position!(image_attachment)
          image_attachments << image_attachment
        end
      end
    end
  end
end
