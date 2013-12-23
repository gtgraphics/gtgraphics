module FlashableController
  extend ActiveSupport::Concern
 
  def flash_for(object, action = nil)
    model_name = object.class.model_name.human
    if action.nil?
      warn 'object should include PersistenceContextTrackable to properly determine whether a record has been created or updated'
      if object.destroyed?
        notice = translate('helpers.flash.destroyed', model: model_name)
      elsif object.created?
        notice = translate('helpers.flash.created', model: model_name)
      elsif object.updated?
        notice = translate('helpers.flash.updated', model: model_name)
      end
    else
      notice = translate(action, scope: 'helpers.flash', model: model_name) if object.errors.empty?
    end
    flash.notice = notice if notice
  end
end