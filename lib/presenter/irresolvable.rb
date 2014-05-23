class Presenter::Irresolvable < StandardError
  attr_reader :model

  def initialize(model)
    @model = model
    super("Presenter could not be resolved from #{model.name} model")
  end
end