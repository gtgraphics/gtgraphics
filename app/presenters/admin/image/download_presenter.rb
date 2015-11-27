module Admin
  module Image
    class DownloadPresenter < Admin::ApplicationPresenter
      include FileAttachablePresenter
      include Admin::MovableResourcePresenter

      presents :image_download
      delegate :title, :image, to: :image_download
      delegate_presented :attachment, with: 'Admin::AttachmentPresenter'

      self.action_buttons = %i(download move_up move_down destroy)

      def download_button(options = {})
        button_options = { active: readable?, icon: :download, caption: :download }
        button :download, default_button_options(options).deep_merge(
          options.reverse_merge(button_options).merge(remote: false)
        )
      end

      # Routes

      delegate :show_path, :download_path, to: :attachment

      def destroy_path
        h.admin_image_attachment_path(image, image_download)
      end

      def edit_path
        h.edit_admin_image_attachment_path(image, image_download)
      end

      def move_down_path
        h.move_down_admin_image_attachment_path(image, image_download)
      end

      def move_up_path
        h.move_up_admin_image_attachment_path(image, image_download)
      end
    end
  end
end
