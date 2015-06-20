class Form
  class FormInvalid < StandardError
    attr_reader :form

    def initialize(form)
      @form = form
    end
  end
end
