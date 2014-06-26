class Page::ProjectPresenter < PagePresenter
  def client
    if project.client_url.present?
      h.link_to project.client_name, project.client_url, target: '_blank'
    else
      project.client_name
    end
  end

  def description
    super.try(:html_safe)
  end

  def project
    page.embeddable
  end
end