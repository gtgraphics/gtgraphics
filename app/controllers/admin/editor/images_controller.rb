class Admin::Editor::ImagesController < Admin::Editor::ApplicationController
  def show
    @editor_image = ::Editor::Image.new
    respond_to do |format|
      format.html
    end
  end

  def update
    @editor_image = ::Editor::Image.new(editor_image_params)
    respond_to do |format|
      format.js do
        if @editor_image.valid?
          render 'update'
        else
          render 'update_failed'
        end
      end
    end
  end

  private
  def editor_image_params
    params.require(:editor_image).permit(:external, :url, :image_id, :alternative_text)
  end
end