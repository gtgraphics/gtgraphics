class Page < ActiveRecord::Base
  class Project < ActiveRecord::Base
    include PageEmbeddable

    acts_as_page_embeddable
  end
end