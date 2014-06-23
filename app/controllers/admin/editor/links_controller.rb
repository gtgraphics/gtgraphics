class Admin::Editor::LinksController < Admin::Editor::ApplicationController
  editor_actions_for :link, params: [:content, :external, :url, :page_id, :locale, :target]
end