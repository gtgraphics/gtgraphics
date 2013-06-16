class RedirectionConstraint
  def matches?(request)
    Redirection.exists?(source_path: request.params[:path])
  end
end