class Admin::SnippetPresenter < Admin::ApplicationPresenter
  presents :snippet

  self.action_buttons -= [:show]
end