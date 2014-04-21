class Routing::LocaleConstraint
  def initialize(param_name = nil)
    @available_locales = I18n.available_locales.map(&:to_s)
    @param_name = param_name || :locale
  end

  def matches?(request)
    locale = request.params[@param_name]
    locale.blank? or locale.in?(@available_locales)
  end
end
