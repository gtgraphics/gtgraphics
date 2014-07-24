class Admin::Editor::ImagesController < Admin::Editor::ApplicationController
  editor_actions_for :image, params: [:external, :url, :image_id, :original_style, :style_id, :alternative_text, :width, :height, :alignment]
end