class Admin::Editor::ImagesController < Admin::Editor::ApplicationController
  editor_actions_for :image

  private
  def image_params
    params.require(:image).permit(:external, :url, :image_id, :image_style, :alternative_text, :width, :height)
  end
end