class Page < ActiveRecord::Base
  module MenuContainable
    extend ActiveSupport::Concern
    
    included do
      scope :menu_items, -> { where(menu_item: true) }
    end

    def disable_in_menu
      self.menu_item = false
    end

    def disable_in_menu!
      update_column(:menu_item, false)
    end

    def enable_in_menu
      self.menu_item = true
    end

    def enable_in_menu!
      update_column(:menu_item, true)
    end
  end
end