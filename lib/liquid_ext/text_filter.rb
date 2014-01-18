module LiquidExt::TextFilter
  def localize(input, format)
    if input.class.name.in? %w(Date DateTime Time)
      if format.nil? or format.in?(I18n.translate('date.formats', raise: true).keys.map(&:to_s))
        I18n.localize(input, format: format.to_sym)
      else
        input
      end
    else
      input
    end
  end
end