class ClientSelectInput < ResourceSelectInput
  def resource_name
    'clients'
  end

  def formatter
    'ClientComboboxFormatter'
  end

  def paginated?
    true
  end

  def url
    template.admin_clients_path(format: :json)
  end
end