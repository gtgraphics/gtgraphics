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
        ::Image::Download.transaction do
          attachment_ids.each do |attachment_id|
            download = image.downloads.create!(attachment_id: attachment_id)
            recalculate_position!(download)
            downloads << download
          end
        end
      end
    end
  end
end
