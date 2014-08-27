class ApplicationPresenter < Presenter
  protected
  def placeholder
    '&ndash;'.html_safe
  end
end