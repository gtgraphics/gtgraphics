# PhantomJS.configure do |config|
#  config.executable_path = "#{Rails.root}/lib/phantomjs"
# end

# PhantomJS.run('my_phantom.js')
# PhantomJS.execute

class PhantomJS
  include Singleton

  class << self
    def configuration
      @@configuration ||= ActiveSupport::InheritableOptions.new
    end

    def configure
      yield(configuration)
    end

    delegate :execute, :run, to: :instance
  end

  class ExecutableNotFound < Exception
    attr_reader :file
    
    def initialize(file)
      @file = file
      if @file
        message = "PhantomJS executable file not found: #{file}"
      else
        message = "PhantomJS executable path not defined"
      end
      super(message)
    end
  end

  class FileNotFound < Exception
    attr_reader :file

    def initialize(file)
      @file = file
      super("PhantomJS file not found: #{file}")
    end
  end

  def execute(script, *args)
    file = Tempfile.new('phantomjs')
    file.write(script)
    result = run(file.path, *args)
    file.close!
    result
  end

  def run(file, *args)
    raise ExecutableNotFound.new(executable_path) if executable_path.nil? or !File.exists?(executable_path)
    raise FileNotFound.new(file) unless File.exists?(file)
    command = [executable_path, file, *args.map(&:to_json)].join(' ')
    %x{#{command}}
  end

  private
  def executable_path
    self.class.configuration.executable_path
  end
end