class Admin::Editor::ImagesController < Admin::Editor::ApplicationController
  editor_actions_for :image

  private
  def image_params
    params.require(:editor_image).permit(:external, :url, :image_id, :style_source, :style_id, :style_name, :alternative_text, :width, :height, :alignment)
  end
end