module GravatarHelper
  def gravatar_image_tag(email, options = {})
    options = options.dup
    size = options.delete(:size)
    default = options.delete(:default) { '404' }
    rating = options.delete(:rating)
    alt = options.delete(:alt) || email
    secure = options.delete(:secure) { request.ssl? }
    email_hash = Digest::MD5.hexdigest(email.strip.downcase)
    url = secure ? "https://secure" : "http://www"
    url << ".gravatar.com/avatar/#{email_hash}"
    query_params = {}
    unless size.nil?
      query_params[:s] = size
      options.merge!(width: size, height: size)
      options[:style] = "width: #{size}px; height: #{size}px; " + options[:style].to_s
      options[:style].strip!
    end
    query_params[:d] = default unless default.nil?
    query_params[:f] = 'y' if options.delete(:force_default)
    query_params[:r] = rating unless rating.nil?
    url << "?#{query_params.to_query}" if query_params.any?
    options.reverse_merge!(alt: alt)
    image_tag url, options
  end
end