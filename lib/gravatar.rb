class Gravatar
  DEFAULTS = {
    default: :not_found,
    force_default: false,
    size: 100,
    secure: false
  }.freeze
  INSECURE_URL = 'http://www.gravatar.com/avatar/%{hash}'
  SECURE_URL = 'https://secure.gravatar.com/avatar/%{hash}'
  VALID_OPTIONS = :size, :default, :rating, :secure, :force_default

  attr_accessor(*VALID_OPTIONS)
  alias_method :force_default?, :force_default
  alias_method :secure?, :secure

  def initialize(email, options = {})
    @email = email.strip.downcase
    options = options.assert_valid_keys(*VALID_OPTIONS).reverse_merge(DEFAULTS)
    options.each do |key, value|
      send("#{key}=", value)
    end
  end

  def digest
    Digest::MD5.hexdigest(@email)
  end

  def url
    base_url = (secure? ? SECURE_URL : INSECURE_URL) % { hash: digest }
    uri = URI.parse(base_url)
    params = {}
    params[:s] = size unless size.nil?
    params[:d] = (default == :not_found) ? '404' : default unless default.nil?
    params[:f] = 'y' if force_default?
    params[:r] = rating unless rating.nil?
    uri.query = params.to_query.presence
    uri.to_s
  end
end
