module Admin
  module Image
    class DownloadsController < Admin::ApplicationController
      before_action :load_image
      before_action :load_image_download, only: %i(move_up move_down destroy)

      def new
        @image_download_assignment_form = ImageDownloadAssignmentForm.new
        @image_download_assignment_form.image = @image

        respond_to :js
      end

      def create
        @image_download_assignment_form = ImageDownloadAssignmentForm.new
        @image_download_assignment_form.image = @image
        @image_download_assignment_form.attributes = image_download_params
        @image_download_assignment_form.submit

        respond_to :js
      end

      def upload
        @image_download = @image.downloads.create!(image_download_upload_params)
        @image_download.with_lock do
          @image_download.update_column(:position, @image.downloads.count)
        end

        respond_to :js
      end

      def destroy
        @image_download.destroy

        respond_to do |format|
          format.js { render :refresh }
        end
      end

      # Position Change

      def move_up
        @image_download.with_lock do
          @image_download.move_higher
        end

        respond_to do |format|
          format.js { render :refresh }
        end
      end

      def move_down
        @image_download.with_lock do
          @image_download.move_lower
        end

        respond_to do |format|
          format.js { render :refresh }
        end
      end

      # Batch Processing

      def batch_process
        if params.key? :destroy
          destroy_multiple
        else
          respond_to do |format|
            format.any { head :unprocessable_entity }
          end
        end
      end

      private

      def load_image
        @image = ::Image.find(params[:image_id])
      end

      def load_image_download
        @image_download = @image.downloads.find(params[:id])
      end

      def image_download_params
        params.require(:image_download_assignment).permit(attachment_ids: [])
      end

      def image_download_upload_params
        params.require(:image_download).permit(:asset)
      end

      def destroy_multiple
        ids = Array(params[:image_download_ids]).map(&:to_i).reject(&:zero?)
        ::Image::Download.accessible_by(current_ability).destroy_all(id: ids)

        flash_for ::Image::Download, :destroyed, multiple: true
        location = request.referer || [:admin, @image]

        respond_to do |format|
          format.html { redirect_to location }
          format.js { redirect_via_turbolinks_to location }
        end
      end
    end
  end
end
