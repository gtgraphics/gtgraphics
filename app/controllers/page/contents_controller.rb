class Page::ContentsController < Page::ApplicationController
  before_action :load_child_pages, only: :show
  before_action :load_query

  def default
    @child_pages = @child_pages.menu_items
    respond_with_page
  end

  def gallery
    @image_pages = @child_pages.images.preload(embeddable: :image)
    if request.format.html?
      @image_pages = @image_pages.page(params[:page]).per(16)
    end
    respond_with_page do |format|
      format.rss { render template_path }
    end
  end

  def gallery_hub
    @gallery_pages = @child_pages.contents.with_template(:gallery)
                     .preload(:embeddable)
    respond_with_page
  end

  def about_hub
    users = User.all.to_a
    @about_pages = @child_pages.each_with_object({}) do |page, pages|
      user = users.find { |u| u.name == page.title }
      pages[user] = page if user
    end
    respond_with_page
  end

  def search
    respond_to do |format|
      format.html { redirect_to page_path(@page, query: @query) }
    end
  end

  private

  def load_query
    @query = params[:query].presence
  end

  def load_child_pages
    @child_pages = @page.children.accessible_by(current_ability)
                   .with_translations_for_current_locale
  end
end