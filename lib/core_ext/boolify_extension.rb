class Object
  def to_b
    self.in?(ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES)
  end
  alias_method :to_bool, :to_b
end