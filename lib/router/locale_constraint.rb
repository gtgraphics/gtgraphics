module Router
  class LocaleConstraint
    def self.available_locales
      @available_locales ||= I18n.available_locales.map(&:to_s)
    end

    def self.valid_locale?(locale)
      locale = locale.to_s
      return false if locale.blank?
      locale.length == 2 && available_locales.include?(locale)
    end

    def initialize(parameter = :locale)
      @parameter = parameter
    end

    def matches?(request)
      locale = request.params[:locale]
      locale.blank? || LocaleConstraint.valid_locale?(locale)
    end
  end
end
