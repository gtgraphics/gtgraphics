class Project < ActiveRecord::Base
  class Translation < Globalize::ActiveRecord::Translation
    validates :name, presence: true
  end
end
