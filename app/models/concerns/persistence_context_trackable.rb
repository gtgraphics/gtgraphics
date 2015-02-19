module PersistenceContextTrackable
  extend ActiveSupport::Concern

  included do
    before_save do
      @record_was_created = new_record?
      true
    end
  end

  def created?
    errors.empty? && persisted? && @record_was_created
  end

  def updated?
    errors.empty? && persisted? && !@record_was_created
  end
end
