class ProjectPresenter < ApplicationPresenter
  presents :project

  def client
    client = project.client
    return placeholder if client.nil?
    h.link_to_if client.website_url.present?, client_name, client.website_url,
                 target: '_blank'
  end

  def description
    super.try(:html_safe)
  end

  def release
    released_on.year
  end
end