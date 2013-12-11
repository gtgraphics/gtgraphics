module GravatarHelper
  DEFAULT_SIZE = 100

  def gravatar_image_tag(email, options = {})
    options[:alt] ||= email
    options[:class] ||= ""
    options[:class] << " gravatar"
    options[:class].strip!
    url = gravatar_image_url(email, options)
    image_tag url, options.except(:size, :default, :rating, :secure, :force_default)
  end

  def gravatar_image_url(email, options = {})
    options = options.dup
    size = options.fetch(:size, DEFAULT_SIZE)
    default = options.fetch(:default) { '404' }
    rating = options[:rating]
    secure = options.fetch(:secure) { request.ssl? }

    email_hash = Digest::MD5.hexdigest(email.strip.downcase)
    
    url = secure ? "https://secure" : "http://www"
    url << ".gravatar.com/avatar/#{email_hash}"
    query_params = {}
    query_params[:s] = size unless size.nil?
    query_params[:d] = default unless default.nil?
    query_params[:f] = 'y' if options[:force_default]
    query_params[:r] = rating unless rating.nil?
    url << "?#{query_params.to_query}" if query_params.any?
    url
  end
end