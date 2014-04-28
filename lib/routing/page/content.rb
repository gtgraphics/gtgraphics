class Routing::Page
  class Content < Routing::Page
    def declare
      action :show
    end
  end
end