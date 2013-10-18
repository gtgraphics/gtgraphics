class Admin::PagesController < Admin::ApplicationController
  respond_to :html

  before_action :load_page, only: %i(show edit update destroy)
  before_action :load_parent_page, only: %i(new create show edit update)

  breadcrumbs do |b|
    b.append Page.model_name.human(count: 2), :admin_pages
    if @parent_page
      @parent_page.self_and_ancestors.each do |page|
        b.append page.title, [:admin, page]
      end
    end
    b.append translate('breadcrumbs.new', model: Page.model_name.human), :new_admin_page if action_name.in? %w(new create)
    b.append @page.title, [:admin, @page] if action_name.in? %w(show edit update)
    b.append translate('breadcrumbs.edit', model: Page.model_name.human), [:edit, :admin, @page] if action_name.in? %w(edit update)
  end

  def index
    @pages = Page.all
    respond_with :admin, @pages
  end

  def new
    @page = Page.new(parent: @parent_page)
    @page.translations.build(locale: I18n.locale)
    respond_with :admin, @page
  end

  def create
    @page = Page.create(page_params)
    respond_with :admin, @page
  end

  def show
    respond_with :admin, @page
  end

  def edit
    respond_with :admin, @page
  end

  def update
    @page.update(page_params)
    respond_with :admin, @page
  end

  def destroy
    @page.destroy
    respond_with :admin, @page
  end

  def preview_path
    @page = Page.new(params.symbolize_keys.slice(:slug, :parent_id))
    @page.valid?
    respond_to do |format|
      format.html { render text: File.join(request.host, @page.path) }
    end
  end

  def translation_fields
    translated_locale = params.fetch(:translated_locale)
    @page = Page.new
    @page.translations.build(locale: translated_locale)
    respond_to do |format|
      format.html do
        if translated_locale.in?(I18n.available_locales.map(&:to_s))
          render layout: false 
        else
          head :not_found
        end
      end
    end
  end

  private
  def load_page
    @page = Page.find(params[:id])
  end

  def load_parent_page
    if params[:parent_id]
      @parent_page = Page.find_by_id(params[:parent_id])
    elsif page_params = params[:page]
      @parent_page = Page.find_by_id(page_params[:parent_id])
    elsif @page
      @parent_page = @page.parent
    end
  end

  def page_params
    params.require(:page).permit! # FIXME
  end
end