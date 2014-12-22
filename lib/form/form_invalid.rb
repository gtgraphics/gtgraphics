class Form
  class FormInvalid < StandardError
    attr_reader :form

    def initialize(form)
      @form = form
      super("Validation failed: #{@form.errors.full_messages.join(', ')}") if @form
    end
  end
end
