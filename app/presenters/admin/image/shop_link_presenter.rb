module Admin
  module Image
    class ShopLinkPresenter < Admin::ApplicationPresenter
      presents :shop_link
      delegate :image, to: :shop_link

      self.action_buttons = %i(edit destroy)

      def destroy_path
        h.admin_image_style_path(image, shop_link)
      end

      def edit_path
        h.edit_admin_image_style_path(image, shop_link)
      end
    end
  end
end
