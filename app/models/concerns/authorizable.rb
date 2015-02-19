module Authorizable
  extend ActiveSupport::Concern

  included do
    delegate :can?, :cannot?, to: :ability
  end

  def ability
    @ability ||= Ability.new(self)
  end
end
