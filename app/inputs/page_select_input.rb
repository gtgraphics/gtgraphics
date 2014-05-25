class PageSelectInput < SimpleForm::Inputs::StringInput
  def input_html_options
    opts = super
    opts.deep_merge(data: {
      resource: 'pages',
      from: '/admin/pages.json',
      formatter: 'PageComboboxFormatter',
      paginated: false,
      include_blank: opts.fetch(:include_blank, false)
    })
  end

  def input_html_classes
    super.push('resource-combobox')
  end
end