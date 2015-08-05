class Page::ContentsController < Page::ApplicationController
  BRICK_PAGE_SIZE = 16

  before_action :load_child_pages

  def default
    @child_pages = @child_pages.menu_items.preload(:embeddable)
    respond_with_page
  end

  def gallery_hub
    @gallery_pages = @child_pages.contents.with_template(:gallery)
                     .preload(:embeddable)
    respond_with_page
  end

  def gallery
    @image_pages = @child_pages.images.preload(embeddable: :image)

    unless params[:format] == 'rss'
      # OPTIMIZE: if request.format.html? caused problems for some crawlers
      @image_pages = @image_pages.page(params[:page]).per(BRICK_PAGE_SIZE)
      fixed_path = fixed_page_path_for(@image_pages)
      return redirect_to(fixed_path) if fixed_path
    end

    respond_with_page do |format|
      format.rss { render template_path }
    end
  end

  def about_hub
    users = User.all.to_a
    @about_pages = @child_pages.each_with_object({}) do |page, pages|
      user = users.find { |u| u.name == page.title }
      pages[user] = page if user
    end
    respond_with_page
  end

  def about
    @user = User.find_by_name(page.title)
    @network_links = @user.social_links.networks if @user
    @contact_form = page.children.contact_forms.first
    respond_with_page
  end

  def showcase_hub
    @showcase_pages = @child_pages.contents.with_template(:showcase)
                      .preload(:embeddable)
    respond_with_page
  end

  def showcase
    @project_pages = @child_pages.projects.preload(embeddable: :project)
                     .page(params[:page]).per(BRICK_PAGE_SIZE)

    fixed_path = fixed_page_path_for(@project_pages)
    return redirect_to(fixed_path) if fixed_path

    respond_with_page
  end

  def prints
    @tobias = User.find_by_name('Tobias Roetsch')
    @tobias_shops = @tobias.social_links.shops.includes(:provider)
    @jeff = User.find_by_name('Jeff Michelmann')
    @jeff_shops = @jeff.social_links.shops.includes(:provider)

    respond_with_page
  end

  private

  def load_child_pages
    @child_pages = @page.children.accessible_by(current_ability).visible
                   .with_translations_for_current_locale
  end

  def fixed_page_path_for(scope)
    total_pages = scope.total_pages
    if scope.current_page < 1
      current_page_path(page: nil)
    elsif total_pages > 0 && scope.current_page > total_pages
      if total_pages == 1
        current_page_path(page: nil)
      else
        current_page_path(page: total_pages)
      end
    end
  end
end
