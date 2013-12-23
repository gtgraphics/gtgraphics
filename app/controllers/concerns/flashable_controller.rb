module FlashableController
  extend ActiveSupport::Concern
 
  def flash_for(object, action = nil)
    model_name = object.class.model_name.human
    if action.nil?
      if object.destroyed?
        notice = translate('helpers.flash.destroyed', model: model_name)
      else
        if object.errors.empty?
          if object.id_changed?
            notice = translate('helpers.flash.created', model: model_name)
          else
            notice = translate('helpers.flash.updated', model: model_name)
          end
        end
      end
    else
      notice = translate(action, scope: 'helpers.flash', model: model_name)
    end
    flash.notice = notice if notice
  end
end