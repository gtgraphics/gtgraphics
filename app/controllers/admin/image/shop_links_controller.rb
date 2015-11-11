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
          format.html
        end
      end

      def create
        @shop_link = @image.shop_links.new(shop_link_params)

        if @shop_link.save
          respond_to do |format|
            format.html
          end
        else
          respond_to do |format|
            format.html { render :edit }
          end
        end
      end

      def edit
        respond_to do |format|
          format.html
        end
      end

      def update
        if @shop_link.update(shop_link_params)
          respond_to do |format|
            format.html
          end
        else
          respond_to do |format|
            format.html { render :edit }
          end
        end
      end

      def destroy
        @shop_link.destroy

        respond_to do |format|
          format.html
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
        params.require(:shop_link).permit! # TODO
      end
    end
  end
end
