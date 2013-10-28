class Admin::Editor::LinksController < Admin::Editor::ApplicationController
  def show
    @editor_link = ::Editor::Link.new(target: params.fetch(:target))
    @editor_link.attributes = params.slice(:caption, :url, :new_window)
    if page = Page.find_by(path: params[:url].to_s[1..-1])
      @editor_link.page = page
    end
    respond_to do |format|
      format.html
    end
  end

  def update
    @editor_link = ::Editor::Link.new(editor_link_params)
    respond_to do |format|
      format.js do
        if @editor_link.valid?
          @editor_link.url = page_path(@editor_link.page, locale: nil) if @editor_link.internal?
          render 'update'
        else
          render 'update_failed'
        end
      end
    end
  end

  private
  def editor_link_params
    params.require(:editor_link).permit(:target, :caption, :external, :url, :page_id, :new_window)
  end
end