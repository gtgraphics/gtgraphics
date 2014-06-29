module PresenterHelper
  def present(*args)
    options = args.extract_options!
    object = args.first
    presenter_class = options.delete(:with) { "#{object.class.name}Presenter" }
    presenter_class = presenter_class.to_s.constantize unless presenter_class.is_a?(Class)
    presenter = presenter_class.new(*[self, object].compact, options)
    yield(presenter) if block_given?
    presenter
  end
end