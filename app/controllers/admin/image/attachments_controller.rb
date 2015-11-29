module Admin
  module Image
    class AttachmentsController < Admin::ApplicationController
      before_action :load_image
      before_action :load_image_attachment, only: %i(move_up move_down destroy)

      def new
        @attachment_assignment_form = Admin::Image::AttachmentAssignmentForm.new
        @attachment_assignment_form.image = @image

        respond_to :js
      end

      def create
        @attachment_assignment_form = Admin::Image::AttachmentAssignmentForm.new
        @attachment_assignment_form.image = @image
        @attachment_assignment_form.attributes =
          image_attachment_assignment_params
        @attachment_assignment_form.submit

        respond_to :js
      end

      def upload
        @attachment_upload_form = Admin::Image::AttachmentUploadForm.new
        @attachment_upload_form.image = @image
        @attachment_upload_form.attributes = image_attachment_upload_params
        @attachment_upload_form.submit

        respond_to do |format|
          format.js { render :refresh }
        end
      end

      def destroy
        @image_attachment.destroy

        respond_to do |format|
          format.js { render :refresh }
        end
      end

      # Position Change

      def move_up
        @image_attachment.with_lock do
          @image_attachment.move_higher
        end

        respond_to do |format|
          format.js { render :refresh }
        end
      end

      def move_down
        @image_attachment.with_lock do
          @image_attachment.move_lower
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

      def load_image_attachment
        @image_attachment = @image.image_attachments.find(params[:id])
      end

      def image_attachment_assignment_params
        params.require(:image_attachment_assignment).permit(:attachment_ids)
      end

      def image_attachment_upload_params
        params.require(:image_attachment_upload).permit(:asset)
      end

      def destroy_multiple
        ids = Array(params[:image_attachment_ids]).map(&:to_i).reject(&:zero?)
        ::Image::Attachment.accessible_by(current_ability).destroy_all(id: ids)

        flash_for ::Image::Attachment, :destroyed, multiple: true
        location = request.referer || [:admin, @image]

        respond_to do |format|
          format.html { redirect_to location }
          format.js { redirect_via_turbolinks_to location }
        end
      end
    end
  end
end
