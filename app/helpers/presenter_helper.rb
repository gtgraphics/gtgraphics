module PresenterHelper
  def present(object, *args)
    options = args.extract_options!
    klass = args.first || "#{object.class}Presenter".constantize
    presenter = klass.new(object, self, options)
    if block_given?
      yield presenter
      presenter
    else
      presenter.render
    end
  end
end