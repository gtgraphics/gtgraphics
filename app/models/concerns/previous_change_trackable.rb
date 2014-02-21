module PreviousChangeTrackable
  extend ActiveSupport::Concern

  included do
    before_save do
      @previously_changed = changes
      true
    end
  end
end