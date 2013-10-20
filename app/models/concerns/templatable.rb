module Templatable
  extend ActiveSupport::Concern

  included do
    belongs_to :template

    validate :validate_template_type

    template_klass = self.const_get(:Template) rescue nil
    template_klass ||= self.const_set(:Template, Class.new(::Template))
  end

  private
  def validate_template_type
    errors.add(:template_id, :invalid) unless template.is_a?(self.const_get(:Template))
  end
end