# composed_of :released_on, class_name: 'LocalizedDate', mapping: %w(released_on to_s), converter: :new

class LocalizedDate < String
  DEFAULT_FORMAT = :default

  attr_reader :locale

  def initialize(date, options = {})
    @format = options.fetch(:format, DEFAULT_FORMAT)
    @locale = options.fetch(:locale, I18n.locale)
    representation = case date
    when String
      date
    when Date
      if @format.is_a?(Symbol)
        date = I18n.localize(date, format: @format, locale: @locale)
      else
        date = date.strftime(@format)
      end
    else
      raise ArgumentError, "unable to convert given #{date.class.name} to #{self.class.name}"
    end
    super(representation)
  end

  def format
    if @format.is_a?(Symbol)
      I18n.translate(@format, scope: 'date.formats', locale: @locale) 
    else
      @format
    end
  end

  def inspect
    "#<#{self.class.name} #{super}, format: #{@format.inspect}, locale: #{@locale.inspect}>"
  end

  def to_date
    Date.strptime(self, @format)
  end

  def valid_date?
    begin
      Date.strptime(self, @format)
      true
    rescue
      false
    end
  end
end