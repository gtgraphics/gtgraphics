module FlashableController
  extend ActiveSupport::Concern
 
  def flash_for(object)
    model_name = object.class.model_name.human
    if object.destroyed?
      notice = translate('flash.destroyed', model: model_name)
    else
      if object.errors.empty?
        if object.id_changed?
          notice = translate('flash.created', model: model_name)
        else
          notice = translate('flash.updated', model: model_name)
        end
      end
    end
    flash.notice = notice if notice
  end
end