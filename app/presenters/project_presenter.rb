class ProjectPresenter < ApplicationPresenter
  presents :project

  def client
    if client = project.client
      h.link_to_if client.website_url.present?, client_name, client.website_url, target: '_blank'
    else
      placeholder
    end
  end

  def description
    super.try(:html_safe)
  end

  def release
    released_on.year
  end
end