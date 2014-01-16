class Routing::RootPageConstraint
  def initialize(type)
    @type = type
    @locale_constraint = Routing::LocaleConstraint.new
  end
  
  def matches?(request)
    @locale_constraint.matches?(request) and Page.published.roots.exists?(embeddable_type: @type)
  end
end