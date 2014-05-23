class Presenter < ResourcelessPresenter
  def initialize(object, template, options = {})
    @object = object
    super(template, options)
  end

  class << self
    def presents(name)
      class_eval <<-RUBY
        def #{name}
          @object
        end
        protected :#{name}
      RUBY
    end
  end

  def inspect
    "#<#{self.class.name} object: #{@object.inspect}>"
  end
end