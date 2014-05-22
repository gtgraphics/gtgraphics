module DecorateHelper
  def decorate(object, options = {})
    options.assert_valid_keys(:with)
    klass = options.fetch(:with) { object.decorator_class }
    klass.decorate(object)
  end
end