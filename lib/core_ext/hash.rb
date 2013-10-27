class Hash
  def camelize_keys(style = :lower)
    dup.camelize_keys!(style)
  end

  def camelize_keys!(style = :lower)
    keys.each do |key|
      self[(key.to_s.camelize(style) rescue key) || key] = delete(key)
    end
    self
  end

  def deep_camelize_keys(style = :lower)
    inject({}) do |result, (key, value)|
      value = value.deep_symbolize_keys if value.is_a?(Hash)
      result[(key.to_s.camelize(style) rescue key) || key] = value
      result
    end
  end
end