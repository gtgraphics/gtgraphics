# composed_of :released_on, class_name: 'LocalizedDate', mapping: %w(released_on to_s), constructor: :parse, converter: :parse

class LocalizedDate < Struct.new(:representation, :format, :locale)
  DEFAULT_FORMAT = :default

  def initialize(*args)
    representation, format, locale = args
    format ||= DEFAULT_FORMAT
    locale ||= I18n.locale
    super(representation, format, locale)
  end

  def self.parse(date, options = {})
    format = options[:format]
    locale = options[:locale]

    representation = case date
    when String
      date
    when Date
      if format.is_a?(Symbol)
        date = I18n.localize(date, format: format, locale: locale)
      else
        date = date.strftime(format)
      end
    else
      raise ArgumentError, "unable to convert given #{date.class.name} to #{self.class.name}"
    end

    new(representation, format, locale)
  end

  def inspect
    "#<#{self.class.name} representation: #{representation.inspect}, format: #{format.inspect}, locale: #{locale.inspect}>"
  end

  def resolved_format
    if format.is_a?(Symbol)
      I18n.translate(format, scope: 'date.formats', locale: locale) 
    else
      format
    end
  end

  def to_date
    Date.strptime(representation, resolved_format)
  end

  def to_s
    representation
  end

  def valid_date?
    begin
      Date.strptime(representation, resolved_format)
      true
    rescue
      false
    end
  end
end
