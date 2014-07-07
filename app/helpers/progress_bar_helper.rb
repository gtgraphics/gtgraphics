module ProgressBarHelper
  def progress_bar(*args)
    options = args.extract_options!

    type = options.delete(:type)
    striped = options.delete(:striped) { false }
    active = options.delete(:active) { false }
    show_percentage = options.delete(:show_percentage) { false }

    options[:class] = Array(options[:class])
    options[:class] << 'progress'

    css = ['progress-bar']
    css << "progress-bar-#{type}" if type
    css << 'progress-bar-striped' if striped
    css << 'active' if active

    progress = (args.first || 0).round
    content_tag :div, options do
      content_tag :div, class: css, role: 'progressbar', style: "width: #{progress}%", 'aria-valuenow' => progress, 'aria-valuemin' => 0, 'aria-valuemax' => 100 do
        content_tag :span, number_to_percentage(progress, precision: 0), class: ['percentage', show_percentage ? nil : 'sr-only']
      end
    end
  end
end