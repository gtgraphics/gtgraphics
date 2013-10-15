class PageConstraint
  def matches?(request)
    path = request.params[:id]
    Page.exists?(path: path)
  end
end