class Admin::Editor::LinksController < Admin::Editor::ApplicationController
  def show
    @link = ::Editor::Link.new
  end

  def update
    @link = ::Editor::Link.new()
  end

  private
  def editor_link_params
    params.require(:editor_link).permit(:url, :new_window)
  end
end