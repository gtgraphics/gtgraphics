class Admin::MessagePresenter < Admin::ApplicationPresenter
  presents :message

  self.action_buttons -= [:edit]

  def contact_form
    h.link_to super.page.title, [:admin, super.page]
  end

  def sender
    h.mail_to super, sender_name
  end

  def recipients
    super.collect do |recipient|
      if recipient.me? 
        I18n.translate('views.admin.account.me')
      else
        h.link_to recipient.full_name, [:admin, recipient]
      end
    end.join(', ').html_safe
  end

  def subject
    super.presence || I18n.translate('helpers.prompts.no_subject')
  end
end