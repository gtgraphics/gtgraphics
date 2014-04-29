class Activity
  class ActivityInvalid < StandardError
    attr_reader :activity
 
    def initialize(activity)
      @activity = activity
      super("Validation failed: #{@activity.errors.full_messages.join(', ')}") if @activity
    end
  end
end