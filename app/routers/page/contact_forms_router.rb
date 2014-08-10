class Page::ContactFormsRouter < Page::ApplicationRouter
  def initialize
    super
    root via: :post, to: :send_message, as: :send_message
  end
end