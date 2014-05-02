module PersistenceContextTrackable
  extend ActiveSupport::Concern

  included do
    before_save do
      @record_was_created = new_record?
      true
    end
  end

  def created?
    errors.empty? and persisted? and @record_was_created
  end

  def updated?
    errors.empty? and persisted? and !@record_was_created
  end
end