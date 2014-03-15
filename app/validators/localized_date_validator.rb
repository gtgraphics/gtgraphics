class LocalizedDateValidator < ActiveModel::EachValidator
  def initialize(options = {})
    super(options.reverse_merge(message: :invalid))
  end

  def validate_each(record, attribute, value)
    if value.is_a?(LocalizedDate) and !value.valid?
      record.errors.add(attribute, options[:message])
    end
  end
end