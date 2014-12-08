class Page::ContentsController < Page::ApplicationController
  before_action :load_child_pages, only: :show
  before_action :load_query

  def default
    @child_pages = @child_pages.menu_items
    respond_with_page
  end

  def gallery
    @image_pages = @child_pages.images.preload(embeddable: :image).search(@query).page(params[:page]).per(16)
    respond_with_page
  end

  def search
    respond_to do |format|
      format.html { redirect_to page_path(@page, query: @query) }
    end
  end

  private
  def load_child_pages
    @child_pages = @page.children.accessible_by(current_ability).with_translations_for_current_locale
  end

  def load_query
    @query = params[:query].presence
  end 
end