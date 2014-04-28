class Routing::Page
  class Homepage < Routing::Page
    def declare
      action :show
    end
  end
end