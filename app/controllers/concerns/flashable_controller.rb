module FlashableController
  extend ActiveSupport::Concern
 
  def flash_for(object, *args)
    options = args.extract_options!.reverse_merge(multiple: false)
    action = args.first

    flashable = true
    if object.class.name.in? %w(Class Symbol String)
      raise ArgumentError, 'action must be specified' if action.nil?
      if object.is_a?(Class)
        klass = object
      else
        klass = object.to_s.classify.constantize
      end
    else
      klass = object.class
      if action.nil?
        # guess what action has been performed on the object shortly
        if object.destroyed?
          action = :destroyed
        elsif object.created?
          action = :created
        elsif object.updated?
          action = :updated
        end
        flashable = object.errors.empty?
      end
    end

    if flashable
      model_name = klass.model_name.human(count: options[:multiple] ? 2 : 1)
      notice = translate(action, scope: ['helpers.flash', klass.name.underscore], model: model_name, default: String.new).presence
      notice ||= translate(action, scope: 'helpers.flash.defaults', model: model_name) 
      flash.notice = notice if notice
    end
  end
end