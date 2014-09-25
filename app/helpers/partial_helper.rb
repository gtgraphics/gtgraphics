module PartialHelper
  def partial_exists?(path)
    path = path.to_s.split('/')
    partial_name = path.pop
    path = path.join('/')
    lookup_context.template_exists?(partial_name, path, true)
  end
  
  def try_render(*args)
    render(*args)
  rescue ActionView::MissingTemplate
  end
end
