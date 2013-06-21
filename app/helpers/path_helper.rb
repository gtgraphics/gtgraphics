module PathHelper
  class << self
    def join_path(*fragments)
      fragments.flatten.join('/')
    end

    def sanitize_path(path)
      sanitize_path(path.dup)
    end

    def sanitize_path!(path)
      path.strip!
      path.gsub!(/\A\/+|\/+\z/, '')
      path
    end
  end

  def sanitize_path(path)
    self.class.sanitize_path(path)
  end

  def sanitize_path!(path)
    self.class.sanitize_path!(path)
  end
end