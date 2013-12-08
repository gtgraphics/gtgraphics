module TimeHelper
  def time_ago(time, *args)
    options = args.extract_options!
    caption = args.first
    caption ||= (I18n.localize(time) rescue time.to_s)
    options[:class] ||= ""
    options[:class] << " timeago"
    options[:class].strip!
    content_tag(:time, caption, options.merge(datetime: time.getutc.iso8601))
  end
  alias_method :in_time, :time_ago
end