module Router
  module Path
    DEFAULT_FORMAT = 'html'

    module_function

    def build_pattern(path)
      pattern_class = ActionDispatch::Journey::Path::Pattern
      if pattern_class.respond_to?(:from_string)
        pattern_class.from_string(path)
      else
        pattern_class.new(path)
      end
    end

    def normalize(path)
      path.to_s.sub(/\A[\/]+/, '')
    end
  end
end
