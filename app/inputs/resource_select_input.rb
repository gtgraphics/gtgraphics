class ResourceSelectInput < SimpleForm::Inputs::StringInput
  def input_html_classes
    super.push('resource-combobox')
  end
  
  def input_html_options
    opts = super
    {
      data: {
        resource: resource_name,
        from: url,
        formatter: formatter,
        paginated: paginated?,
        include_blank: opts.fetch(:include_blank, false),
        multiple: multiple?
      }
    }.deep_merge(opts)
  end

  protected
  def formatter
    raise NotImplementedError
  end

  def multiple?
    options.fetch(:multiple, false)
  end

  def paginated?
    false
  end

  def resource_name
    raise NotImplementedError
  end

  def url
    raise NotImplementedError
  end
end