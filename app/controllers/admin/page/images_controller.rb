class Admin::Page::ImagesController < Admin::Page::ApplicationController
  def new
    @image_page_creation_form = Admin::ImagePageCreationForm.new do |a|
      a.template = "Template::Image".constantize.default
      a.parent_page = @page
    end
    respond_to do |format|
      format.js
    end
  end

  def create
    @image_page_creation_form = Admin::ImagePageCreationForm.submit(image_page_creation_form_params) do |a|
      a.parent_page = @page
    end
    if @image_page_creation_form.errors.empty?
      @location = admin_page_path(@image_page_creation_form.parent_page)
    end
    respond_to do |format|
      format.js
    end
  end

  private

  def image_page_creation_form_params
    params.require(:image_page_creation_form).permit(:image_id_tokens, :template_id, :published)
  end
end
