class Routing::LocaleConstraint
  def initialize
    @available_locales = I18n.available_locales.map(&:to_s)
  end

  def matches?(request)
    locale = request.params[:locale]
    locale.blank? or locale.in?(@available_locales)
  end
end
