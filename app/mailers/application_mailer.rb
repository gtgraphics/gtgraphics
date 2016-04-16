class ApplicationMailer < ActionMailer::Base
  DEFAULT_SENDER = %("GTGRAPHICS" <noreply@gtgraphics.de>).freeze

  default from: DEFAULT_SENDER, sender: DEFAULT_SENDER
end
