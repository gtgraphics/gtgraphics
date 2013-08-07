class MenuItem::Link < ActiveRecord::Base
  include MenuItemTarget
end