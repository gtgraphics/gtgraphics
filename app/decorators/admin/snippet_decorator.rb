class Admin::SnippetDecorator < Admin::ApplicationDecorator
  decorates :snippet

  self.action_buttons -= [:show]
end