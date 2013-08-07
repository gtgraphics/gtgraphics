module MenuItemTarget
  extend ActiveSupport::Concern

  included do
    has_one :menu_item, as: :menu_item_target
  end
end