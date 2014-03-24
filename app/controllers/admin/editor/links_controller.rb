class Admin::Editor::LinksController < Admin::Editor::ApplicationController
  editor_actions_for :image

  private
  def link_params
    params.require(:link).permit(:caption, :external, :url, :page_id, :locale, :target)
  end
end