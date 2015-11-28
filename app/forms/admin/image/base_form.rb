module Admin
  module Image
    class BaseForm < Form
      attr_accessor :image

      validates :image, presence: true, strict: true

      before_validation do
        downloads.clear
      end

      def downloads
        @downloads ||= []
      end

      private

      def recalculate_position!(download)
        download.with_lock do
          download.update_column(:position, image.downloads.count)
        end
      end
    end
  end
end
