class Routing::Page
  class ContactForm < Routing::Page
    def declare
      action :show, via: [:get, :post]
    end
  end
end