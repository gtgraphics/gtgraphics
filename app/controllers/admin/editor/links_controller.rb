class Admin::Editor::LinksController < Admin::Editor::ApplicationController
  include Admin::Editor::DialogProvidingController
  
  editor_actions_for :link

  private
  def link_params
    params.require(:editor_link).permit(:content, :external, :url, :page_id, :locale, :target)
  end
end