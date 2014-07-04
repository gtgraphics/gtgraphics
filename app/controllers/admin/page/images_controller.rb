class Admin::Page::ImagesController < Admin::Page::ApplicationController
  def new
    @image_page_creation_activity = Admin::ImagePageCreationActivity.new do |a|
      a.template = "Template::Image".constantize.default
      a.parent_page = @page
    end
    respond_to do |format|
      format.js
    end
  end

  def create
    @image_page_creation_activity = Admin::ImagePageCreationActivity.execute(image_page_creation_activity_params) do |a|
      a.parent_page = @page
    end
    if @image_page_creation_activity.errors.empty?
      if @image_page_creation_activity.pages.many?
        # if many pages have been created, redirect to parent
        page = @image_page_creation_activity.parent_page
      else
        page = @image_page_creation_activity.pages.first
      end
      @location = admin_page_path(page)
    end
    respond_to do |format|
      format.js
    end
  end

  private
  def image_page_creation_activity_params
    params.require(:image_page_creation_activity).permit(:image_id_tokens, :template_id, :published)
  end
end