class Gravatar
  DEFAULTS = {
    default: :not_found,
    force_default: false,
    size: 100,
    secure: false
  }.freeze
  INSECURE_URL = "http://www.gravatar.com/avatar/%{hash}"
  SECURE_URL = "https://secure.gravatar.com/avatar/%{hash}"
  VALID_OPTIONS = :size, :default, :rating, :secure, :force_default
  
  attr_reader :email, :size, :default, :rating
  attr_writer *VALID_OPTIONS
  
  def initialize(email, options = {})
    @email = email.strip.downcase
    options.assert_valid_keys(*VALID_OPTIONS).reverse_merge(DEFAULTS).each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def digest
    Digest::MD5.hexdigest(email)
  end
  
  def force_default?
    @force_default
  end
  
  def secure?
    @secure
  end
  
  def url
    base_url = (self.secure? ? SECURE_URL : INSECURE_URL) % { hash: self.digest }
    uri = URI.parse(base_url)
    params = {}
    params[:s] = self.size unless self.size.nil?
    unless self.default.nil?
      params[:d] = (self.default == :not_found) ? '404' : self.default
    end
    params[:f] = 'y' if self.force_default?
    params[:r] = self.rating unless self.rating.nil?
    uri.query = params.to_query.presence
    uri.to_s
  end
end