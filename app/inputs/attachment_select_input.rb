class AttachmentSelectInput < ResourceSelectInput
  def resource_name
    'attachments'
  end

  def formatter
    'AttachmentComboboxFormatter'
  end

  def paginated?
    true
  end

  def url
    template.admin_attachments_path(format: :json)
  end
end
