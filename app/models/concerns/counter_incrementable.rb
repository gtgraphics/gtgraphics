module CounterIncrementable
  def increment_counter!(name)
    if persisted?
      id = self[self.class.primary_key]
      self.class.where(self.class.primary_key => id)
        .update_all("#{name}_count = COALESCE(#{name}_count, 0) + 1")
    end
    self
  end
end
