class LocalizedDate < String
  DEFAULT_FORMAT = :default

  attr_reader :options

  def initialize(*args)
    options = args.extract_options!
    options.assert_valid_keys(:format, :locale)
    @options = options.reverse_merge(format: DEFAULT_FORMAT, locale: I18n.locale)
    super(*args)
  end

  def self.parse(date, options = {})
    options = options.reverse_merge(format: DEFAULT_FORMAT, locale: I18n.locale)
    if date.is_a?(Date)
      format = options[:format]
      if format.is_a?(Symbol)
        date = I18n.localize(date, format: format, locale: options[:locale])
      else
        date = date.strftime(format)
      end
    end
    new(date, options)
  end

  def format
    if options[:format].is_a?(Symbol)
      I18n.translate(options[:format], scope: 'date.formats', locale: options[:locale]) 
    else
      options[:format]
    end
  end

  def to_date
    Date.strptime(self, format)
  end

  def valid?
    begin
      Date.strptime(self, format)
      true
    rescue
      false
    end
  end
end