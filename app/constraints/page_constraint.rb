class PageConstraint
  def matches?(request)
    Page.exists?(path: request.params[:path])
  end
end