class Admin::Editor::ImagesController < Admin::Editor::ApplicationController
  editor_actions_for :image

  private
  def image_params
    params.require(:editor_image).permit(:external, :url, :image_id, :original_style, :style, :alternative_text, :width, :height, :alignment)
  end
end