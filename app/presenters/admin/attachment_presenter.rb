class Admin::AttachmentPresenter < Admin::ApplicationPresenter
  include AssetContainablePresenter

  presents :attachment

  self.action_buttons -= [:show]
end