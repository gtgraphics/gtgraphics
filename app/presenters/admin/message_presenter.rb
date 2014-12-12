class Admin::MessagePresenter < Admin::ApplicationPresenter
  presents :message

  self.action_buttons -= [:edit]

  def delegator
    if message.is_a?(Message::Contact)
      h.link_to contact_form.page.title, [:admin, contact_form.page]
    else
      h.link_to image.title, [:admin, image]
    end
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
    if message.is_a?(Message::BuyRequest)
      default_subject = I18n.t('views.admin.messages.buy_request_subject',
                               image: message.image)
    else
      default_subject = I18n.translate('helpers.prompts.no_subject')
    end
    super.presence || default_subject
  end

  # Paths

  def abstract_message
    message.becomes(Message)
  end

  def show_path
    h.admin_message_path(abstract_message, locale: I18n.locale)
  end

  def edit_path
    h.edit_admin_message_path(abstract_message, locale: I18n.locale)
  end
end