class Page::ProjectPresenter < Page::ApplicationPresenter
  presents :project_page

  def client
    h.link_to_if client_url.present?, client_name, client_url, target: '_blank'
  end

  def description
    super.try(:html_safe)
  end

  def release
    released_on.year
  end

  def twitter_share_text
    twitter_username = project_page.project.author.try(:twitter_username)
    I18n.translate twitter_username.present? ? :owned : :ownerless,
                   scope: ['page/project', :twitter_share_text],
                   title: project_page.project.title,
                   author: twitter_username
  end
end
