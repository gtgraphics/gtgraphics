class Authenticatable::AccessDenied < Exception
  def initialize(message = nil)
    message ||= "You are not authenticated and therefore are not permitted to access this page."
    super(message)
  end
end