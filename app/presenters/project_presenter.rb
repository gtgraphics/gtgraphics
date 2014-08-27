class ProjectPresenter < ApplicationPresenter
  presents :project

  def client
    h.link_to_if client_url.present?, client_name, client_url, target: '_blank'
  end

  def description
    super.try(:html_safe)
  end

  def release
    released_on.year
  end
end