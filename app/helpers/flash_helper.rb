module FlashHelper
  def render_flashes
    capture do
      concat render_flash(:success, flash.notice)
      concat render_flash(:danger, flash.alert)
      concat render_flash(:warning, flash[:warning])
      concat render_flash(:info, flash[:info])
    end
  end

  def render_flash(type, *args, &block)
    options = args.extract_options!
    message = block_given? ? capture(&block) : args.first
    return if message.blank?

    dismissable = options.delete(:dismissable, false)

    options[:class] ||= ''
    options[:class] << " alert alert-#{type}"
    options[:class] << ' alert-dismissable' if dismissable
    options[:class].strip!

    content_tag :div, options do
      if dismissable
        concat button_tag(icon(:times), name: nil, type: 'button',
                                        class: 'close',
                                        data: { dismiss: 'alert' },
                                        'aria-hidden' => true)
      end
      concat message
    end
  end
end
