class Admin::AttachmentPresenter < Admin::ApplicationPresenter
  include FileAttachablePresenter

  presents :attachment

  self.action_buttons -= [:show]
end