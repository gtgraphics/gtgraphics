class Admin::Editor::LinksController < Admin::Editor::ApplicationController
  editor_actions_for :link

  private
  def link_params
    params.require(:editor_link).permit(:caption, :external, :url, :page_id, :locale, :target)
  end
end