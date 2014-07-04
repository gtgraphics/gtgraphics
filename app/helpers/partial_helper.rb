module PartialHelper
  def partial_exists?(path)
    path = path.to_s.split('/')
    partial_name = path.pop
    lookup_context.template_exists?(partial_name, path, true)
  end
end
