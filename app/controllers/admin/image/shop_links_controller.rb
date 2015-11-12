module Admin
  module Image
    class ShopLinksController < Admin::ApplicationController
      before_action :load_image
      before_action :load_shop_link, only: %i(edit update destroy)

      breadcrumbs do |b|
        b.append ::Image.model_name.human(count: 2), :admin_images
        b.append @image.title, [:admin, @image]
        if action_name.in? %w(new create)
          b.append translate('breadcrumbs.new', model: ::Image::ShopLink.model_name.human), [:new, :admin, @image, :shop_link]
        end
        if action_name.in? %w(edit crop update)
          b.append translate('breadcrumbs.edit', model: ::Image::ShopLink.model_name.human), edit_admin_image_shop_link_path(@image, @shop_link)
        end
      end

      def new
        @shop_link = @image.shop_links.new

        respond_to do |format|
          format.js
        end
      end

      def create
        @shop_link = @image.shop_links.create(shop_link_params)
        load_shop_links

        respond_to do |format|
          format.js
        end
      end

      def edit
        respond_to do |format|
          format.js
        end
      end

      def update
        @shop_link.update(shop_link_params)
        load_shop_links

        respond_to do |format|
          format.js
        end
      end

      def destroy
        @shop_link.destroy
        load_shop_links

        respond_to do |format|
          format.js
        end
      end

      private

      def load_image
        @image = ::Image.find(params[:image_id])
      end

      def load_shop_link
        @shop_link = @image.shop_links.find(params[:id])
      end

      def shop_link_params
        params.require(:image_shop_link).permit(:provider_id, :url)
      end

      def load_shop_links
        @shop_links = @image.shop_links.eager_load(:provider)
                      .order('providers.name')
      end
    end
  end
end
