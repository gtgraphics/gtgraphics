class ResourceSelectInput < SimpleForm::Inputs::StringInput
  def input_html_classes
    super.push('resource-combobox')
  end
  
  def input_html_options
    opts = super
    include_blank = opts.delete(:include_blank) { false }
    {
      data: {
        resource: resource_name,
        from: url,
        formatter: formatter,
        paginated: paginated?,
        include_blank: include_blank,
        multiple: multiple?,
        allow_non_existing: allow_non_existing?
      }
    }.deep_merge(opts)
  end

  protected
  def formatter
    # raise NotImplementedError
  end

  def allow_non_existing?
    false
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