module FlashableController
  extend ActiveSupport::Concern
 
  def flash_for(object, *args)
    return unless request.format.html?
    
    options = args.extract_options!.reverse_merge(multiple: false, successful: true)
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
      affixed_action = ''
      affixed_action << 'not_' unless options[:successful]
      affixed_action << action.to_s
      affixed_action << '_multiple' if options[:multiple]
      message = translate(affixed_action, scope: ['helpers.flash', klass.name.underscore], model: model_name, default: String.new).presence
      message ||= translate(affixed_action, scope: 'helpers.flash.defaults', model: model_name) 
      if message
        if options[:successful]
          flash.notice = message
        else
          flash.alert = message
        end
      end
      
    end
  end
end