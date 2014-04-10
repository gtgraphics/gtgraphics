module GlobalizedModelTouchable
  extend ActiveSupport::Concern

  included do
    after_commit :touch_globalized_model
  end

  private
  def touch_globalized_model
    globalized_model.touch
  end
end