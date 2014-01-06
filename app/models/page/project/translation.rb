class Page < ActiveRecord::Base
  class Project < ActiveRecord::Base
    class Translation < Globalize::ActiveRecord::Translation
    end
  end
end