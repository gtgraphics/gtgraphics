class ProjectPresenter < ApplicationPresenter
  presents :project

  delegate_presented :author

  def description
    super.try(:html_safe) if h.html_present?(super)
  end

  def release
    released_on.year
  end
end
