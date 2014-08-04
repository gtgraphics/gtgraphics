class Page::ContactFormsRouter < Page::ApplicationRouter
  def declare
    root
    root via: :post, to: :send_message, as: :send_message
  end
end