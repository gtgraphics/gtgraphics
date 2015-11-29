module Admin
  module Image
    class BaseForm < Form
      attr_accessor :image

      validates :image, presence: true, strict: true

      before_validation do
        image_attachments.clear
      end

      def image_attachments
        @image_attachments ||= []
      end

      private

      def recalculate_position!(attachment)
        attachment.with_lock do
          attachment.update_column(:position, image.image_attachments.count)
        end
      end
    end
  end
end
