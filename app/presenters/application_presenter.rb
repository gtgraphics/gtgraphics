class ApplicationPresenter < ActionPresenter::Base
  protected
  def placeholder
    '&ndash;'.html_safe
  end
end