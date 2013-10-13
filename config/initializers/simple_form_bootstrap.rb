# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  config.wrappers :bootstrap, tag: :div, class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper :container, tag: :div do |input|
      input.use :input
      input.use :error, wrap_with: { tag: :span, class: 'help-block' }
      input.use :hint,  wrap_with: { tag: :span, class: 'help-block' }
    end
  end

  config.wrappers :prepend, tag: :div, class: "form-group", error_class: 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper :container, tag: :div, class: 'controls' do |input|
      input.wrapper tag: :div, class: 'input-prepend' do |prepend|
        prepend.use :input
      end
      input.use :error, wrap_with: { tag: :span, class: 'help-block' }
      input.use :hint,  wrap_with: { tag: :span, class: 'help-block' }
    end
  end

  config.wrappers :append, tag: :div, class: "form-group", error_class: 'error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper tag: :div, class: 'controls' do |input|
      input.wrapper tag: :div, class: 'input-append' do |append|
        append.use :input
      end
      input.use :error, wrap_with: { tag: :span, class: 'help-block' }
      input.use :hint,  wrap_with: { tag: :span, class: 'help-block' }
    end
  end

  # Wrappers for forms and inputs using the Twitter Bootstrap toolkit.
  # Check the Bootstrap docs (http://twitter.github.com/bootstrap)
  # to learn about the different styles for forms and inputs,
  # buttons and other elements.
  config.default_wrapper = :bootstrap
end

class SimpleForm::Inputs::Base
  FORM_CONTROL_INPUT_TYPES = %w(
    CollectionSelectInput
    DateTimeInput
    FileInput
    GroupedCollectionSelectInput
    NumericInput
    PasswordInput
    RangeInput
    StringInput
    TextInput
  )

  def input_html_classes
    if self.class.name.demodulize.in? FORM_CONTROL_INPUT_TYPES
      @input_html_classes << 'form-control'
    else
      @input_html_classes
    end
  end
end