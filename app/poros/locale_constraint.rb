class LocaleConstraint
  def initialize
    @available_locales = I18n.available_locales.map(&:to_s)
  end

  def matches?(request)
    locale = request.params[:locale]
    locale.nil? or @available_locales.include?(locale)
  end
end