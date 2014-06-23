class Admin::Editor::ImagesController < Admin::Editor::ApplicationController
  editor_actions_for :image, params: [:external, :url, :image_id, :original_style, :style, :alternative_text, :width, :height, :alignment]
end