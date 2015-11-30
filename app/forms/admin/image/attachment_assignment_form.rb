module Admin
  module Image
    class AttachmentAssignmentForm < BaseForm
      embeds_many :attachments

      validates :attachment_ids, presence: true

      def attachment_ids=(attachment_ids)
        if attachment_ids.is_a?(String)
          attachment_ids = attachment_ids.split(',')
                           .map(&:to_i).reject(&:zero?)
        end
        super(attachment_ids)
      end

      def perform
        ::Image::Attachment.transaction do
          attachment_ids.each do |attachment_id|
            image_attachment =
              image.image_attachments.create!(attachment_id: attachment_id)
            recalculate_position!(image_attachment)
            image_attachments << image_attachment
          end
        end
      end
    end
  end
end
