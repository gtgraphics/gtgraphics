class Admin::MessagePresenter < Admin::ApplicationPresenter
  presents :message

  self.action_buttons -= [:edit]

  def recipients
    super.collect do |recipient|
      if recipient.current_user? 
        I18n.translate('views.admin.account.me')
      else
        h.link_to recipient.full_name, [:admin, recipient]
      end
    end.join(', ').html_safe
  end

  def subject
    super.presence || translate('helpers.prompts.no_subject')
  end
end