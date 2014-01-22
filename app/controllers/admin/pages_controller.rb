class Admin::PagesController < Admin::ApplicationController
  respond_to :html

  before_action :load_page, only: %i(show edit update destroy toggle_menu_item move_up move_down publish draft hide)
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
    @pages = Page.with_translations(I18n.locale).where(depth: 0..2)
    @page = Page.root
    respond_with :admin, @pages
  end

  def new
    @page = Page.new(parent: @parent_page || Page.root)
    @page.translations.build(locale: I18n.locale)
    @page.embeddable_type = params[:type] || 'Page::Content'
    if @page.embeddable_class and @page.embeddable.nil?
      @page.embeddable = @page.embeddable_class.new
      if @page.embeddable_class.reflect_on_association(:translations)
        @page.embeddable.translations.build(locale: I18n.locale)
      end
    end
    respond_with :admin, @page, layout: !request.xhr?
  end

  def create
    @page = Page.create(page_params)
    flash_for @page
    respond_with :admin, @page
  end

  def show
    @pages = @page.self_and_ancestors_and_siblings.with_translations(I18n.locale)
    respond_with :admin, @page, layout: !request.xhr?
  end

  def edit
    respond_with :admin, @page, layout: !request.xhr?
  end

  def update
    @page.update(page_params)
    flash_for @page
    respond_with :admin, @page
  end

  def destroy
    @page.destroy
    flash_for @page
    respond_with :admin, @page
  end

  def publish
    @page.publish!
    respond_to do |format|
      format.html { redirect_to request.referer || [:admin, @page] }
    end
  end

  def draft
    @page.draft!
    respond_to do |format|
      format.html { redirect_to request.referer || [:admin, @page] }
    end
  end

  def hide
    @page.hide!
    respond_to do |format|
      format.html { redirect_to request.referer || [:admin, @page] }
    end
  end

  def toggle_menu_item
    @page.toggle!(:menu_item)
    respond_to do |format|
      format.html { redirect_to request.referer || [:admin, @page] }
    end
  end

  def move_up
    @page.move_left
    respond_to do |format|
      format.html { redirect_to request.referer || :admin_pages }
    end
  end

  def move_down
    @page.move_right
    respond_to do |format|
      format.html { redirect_to request.referer || :admin_pages }
    end
  end

  def tree_items
    @parent_page = Page.find(params.fetch(:parent_id))
    @pages = @parent_page.children.with_translations(I18n.locale)
    respond_to do |format|
      format.html { render layout: false }
    end
  end

  def preview_path
    @page = Page.new(params.symbolize_keys.slice(:slug, :parent_id))
    @page.valid?
    respond_to do |format|
      format.html { render text: @page.slug.present? ? File.join(request.host, @page.path) : '' }
    end
  end

  def embeddable_fields
    embeddable_type = params.fetch(:embeddable_type)
    translated_locales = params.fetch(:translated_locales)

    @page = Page.new(embeddable_type: embeddable_type)
    if @page.embeddable_class
      @page.embeddable ||= @page.embeddable_class.new
      if @page.embeddable_class.reflect_on_association(:translations)
        translated_locales.each do |translated_locale|
          @page.embeddable.translations.build(locale: translated_locale)
        end
      end
    end

    respond_to do |format|
      format.html do
        if @page.embeddable_class
          render layout: false
        else
          head :not_found
        end
      end
    end
  end

  def embeddable_translation_fields
    embeddable_type = params.fetch(:embeddable_type)
    translated_locale = params.fetch(:translated_locale)

    @page = Page.new(embeddable_type: embeddable_type)
    if @page.embeddable_class
      @page.embeddable ||= @page.embeddable_class.new
      if @page.embeddable_class.reflect_on_association(:translations)
        @page.embeddable.translations.build(locale: translated_locale)
      end
    end

    respond_to do |format|
      format.html do
        if @page.embeddable_class
          render layout: false
        else
          head :not_found
        end
      end
    end
  end

  def translation_fields
    embeddable_type = params.fetch(:embeddable_type)
    translated_locale = params.fetch(:translated_locale)

    @page = Page.new(embeddable_type: embeddable_type)
    @page.translations.build(locale: translated_locale)
    if @page.embeddable_class
      @page.embeddable ||= @page.embeddable_class.new
      if @page.embeddable_class.reflect_on_association(:translations)
        @page.embeddable.translations.build(locale: translated_locale)
      end
    end

    respond_to do |format|
      format.js do
        if @page.embeddable_class
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
    if parent_id = params[:parent_id]
      @parent_page = Page.find_by_id(parent_id)
    elsif page_params = params[:page]
      @parent_page = Page.find_by_id(page_params[:parent_id])
    elsif @page
      @parent_page = @page.parent
    end
  end

  def page_params
    page_params = params.require(:page)
    embeddable_attributes_params = case page_params[:embeddable_type]
    when 'Page::ContactForm' then [:id, :template_id, { recipient_ids: [], translations_attributes: [:_destroy, :id, :locale, :title, :description] }]
    when 'Page::Content' then [:id, :template_id, { translations_attributes: [:_destroy, :id, :locale, :title, :body] }]
    when 'Page::Homepage' then [:id, :template_id]
    when 'Page::Image' then [:id, :template_id, :asset, :image_id, :author_id, { translations_attributes: [:_destroy, :id, :locale, :title, :description] }]
    when 'Page::Project' then [:id, :template_id, :client_name, :client_url, :released_on, { translations_attributes: [:_destroy, :id, :locale, :name, :description] }]
    when 'Page::Redirection' then [:id, :external, :destination_page_id, :destination_url, :permanent, { translations_attributes: [:_destroy, :id, :locale, :title, :description] }]
    end
    page_params.permit(:embeddable_id, :embeddable_type, :slug, :parent_id, :state, :menu_item, :indexable, translations_attributes: [:_destroy, :id, :locale, :title, :meta_keywords, :meta_description], embeddable_attributes: embeddable_attributes_params || {}) 
  end
end