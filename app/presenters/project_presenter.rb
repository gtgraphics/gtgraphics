class ProjectPresenter < ApplicationPresenter
  presents :project

  delegate_presented :author

  # def client
  #   client = project.client
  #   return nil if client.nil?
  #   h.link_to_if client.website_url.present?, client_name, client.website_url,
  #                target: '_blank'
  # end

  def description
    super.try(:html_safe)
  end

  def release
    released_on.year
  end
end
