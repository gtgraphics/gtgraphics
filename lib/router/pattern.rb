module Router
  module Pattern
    module_function

    def build(pattern_string)
      pattern_class = ActionDispatch::Journey::Path::Pattern
      if pattern_class.respond_to?(:from_string)
        pattern_class.from_string(pattern_string)
      else
        pattern_class.new(pattern_string)
      end
    end

    def match(path, pattern_string)
      build(pattern_string).match(path)
    end

    def extract_params(path, pattern_string)
      match = match(path, pattern_string)
      match.names.zip(match.captures).to_h.with_indifferent_access if match
    end
  end
end
