class Admin::Editor::LinksController < Admin::Editor::ApplicationController
  def show
    @editor_link = ::Editor::Link.new(params.slice(:caption, :target))
    @editor_link.external = false
    uri = URI.parse(params[:url]) if params[:url]
    if uri.present?
      @editor_link.editing = true
      local_uri = (uri.relative? or (uri.host == request.host and uri.port == request.port))
      route = Rails.application.routes.recognize_path(uri.to_s) rescue nil
      if local_uri and route.present? and route.key?(:id)
        if page = Page.find_by(path: route[:id])
          @editor_link.external = false
          @editor_link.page = page
        end
      else
        @editor_link.external = true
        @editor_link.url = uri.to_s
      end
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
          render 'update'
        else
          render 'update_failed'
        end
      end
    end
  end

  private
  def editor_link_params
    params.require(:editor_link).permit(:caption, :external, :url, :page_id, :target)
  end
end