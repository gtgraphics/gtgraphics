module ButtonHelper
  def active_button_link_to(*args, &block)
    args = sanitize_button_options!(*args)
    active_link_to *args, &block
  end

  def button_link_to(*args, &block)
    args = sanitize_button_options!(*args)
    link_to *args, &block
  end

  def button_link_to_if(condition, *args, &block)
    args = sanitize_button_options!(*args)
    if condition
      link_to *args, &block
    else
      options = args.extract_options!
      options[:class] = [*options[:class], 'disabled'].uniq
      content_tag :div, block_given? ? capture(&block) : args.first, options
    end
  end

  def button_link_to_unless(condition, *args, &block)
    button_link_to_if !condition, *args, &block
  end

  def button_mail_to(*args, &block)
    args = sanitize_button_options!(*args)
    mail_to *args, &block
  end

  private

  def sanitize_button_options!(*args)
    options = args.extract_options!.dup

    type = options.delete(:as) || options.delete(:type) || 'default'
    size = options.delete(:size).to_s
    size = case size
           when 'mini' then 'xs'
           when 'small' then 'sm'
           when 'large' then 'lg'
           else size.presence
           end
    block_mode = options.delete(:block)

    options[:class] = Array(options[:class]) << 'btn'
    options[:class] << "btn-#{type.to_s.dasherize}" if type
    options[:class] << "btn-#{size}" if size
    options[:class] << 'btn-block' if block_mode
    options[:class] << 'disabled' if options.delete(:disabled)
    options[:class] = options[:class].flatten.compact.uniq

    options[:role] ||= 'button'

    [*args, options]
  end
end
