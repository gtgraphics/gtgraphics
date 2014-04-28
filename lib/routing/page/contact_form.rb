class Routing::Page
  class ContactForm < Routing::Page
    def declare
      action :show
    end
  end
end