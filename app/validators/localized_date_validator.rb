class LocalizedDateValidator < ActiveModel::EachValidator
  def initialize(options = {})
    super(options.reverse_merge(message: :invalid))
  end

  def validate_each(record, attribute, value)

    if value.is_a?(LocalizedDate) and !value.valid?
      record.errors.add(attribute, options[:message])
    end

    schemes = options.fetch(:schemes)
    schemes = Array(schemes).map(&:to_s) unless schemes == :all
    uri = URI.parse(value)
    if uri.host.nil? or !uri.scheme.in?(schemes)
      record.errors.add(attribute, options.fetch(:message), url: value)
    end
  end
end