class Routing::LegacyConstraint
  protected
  def path_matcher(request)
    slug = Regexp.escape(request.params[:slug])
    /\/#{slug}\z/
  end
end