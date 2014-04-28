class Routing::Page
  class Redirection < Routing::Page
    def declare
      action :show
    end
  end
end