class Admin::GalleriesController < Admin::ApplicationController
  def translation_fields
    respond_to do |format|
      format.html
    end
  end
end