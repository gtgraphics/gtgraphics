if Rails.env.in? %w(staging production)
  ExceptionNotification.configure do |config|
    config.add_notifier :email, email_prefix: "[#{Rails.env}] ",
                                sender_address: %("GTGRAPHICS Exception Notifier" <noreply@gtgraphics.de>),
                                exception_recipients: %w(webmaster@gtgraphics.de)
  end
end
