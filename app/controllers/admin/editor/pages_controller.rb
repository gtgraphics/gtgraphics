class Admin::Editor::PagesController < Admin::Editor::ApplicationController
  layout 'page_editor'

  before_action :load_page_path

  def edit
    respond_to do |format|
      format.html
    end
  end

  def update
    respond_to do |format|
      format.html { head :ok }
    end
  end

  private
  def load_page_path
    @path = "/" + params[:path]
  end
end