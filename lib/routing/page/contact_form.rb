class Routing::Page
  class ContactForm < Routing::Page
    def declare
      action :show, via: :get
      action :show, via: :post, action: :send_message, as: :send_contact_message
    end
  end
end