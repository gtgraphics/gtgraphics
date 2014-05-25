class Routing::Page
  class Gallery < Routing::Page
    def declare
      action :show
    end
  end
end