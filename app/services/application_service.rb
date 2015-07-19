class ApplicationService
  def self.call(*args)
    new(*args).call
  end

  def call
    fail NotImplementedError, "#{self.class.name}#perform must be overridden"
  end
end
