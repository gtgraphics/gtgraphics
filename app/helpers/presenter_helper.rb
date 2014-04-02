module PresenterHelper
  def present(object, *args)
    options = args.extract_options!
    klass = args.first || begin
      if object.is_a?(ActiveRecord::Relation)
        "#{object.klass.name.pluralize}Presenter".constantize
      else
        "#{object.class}Presenter".constantize
      end
    end
    presenter = klass.new(object, self, options)
    if block_given?
      yield presenter
      presenter
    else
      presenter.render
    end
  end
end