class Routing::Page
  class Project < Routing::Page
    def declare
      action :show
    end
  end
end