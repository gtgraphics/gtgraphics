class UrlValidator < ActiveModel::EachValidator
  def initialize(options = {})
    super(options.reverse_merge(schemes: %w(http https), message: :invalid_url))
  end

  def validate_each(record, attribute, value)
    schemes = options.fetch(:schemes)
    schemes = Array(schemes).map(&:to_s) unless schemes == :all
    uri = URI.parse(value) rescue nil
    if uri.nil? or uri.host.nil? or !uri.scheme.in?(schemes)
      record.errors.add(attribute, options.fetch(:message), url: value)
    end
  end
end