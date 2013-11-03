class Admin::PagesController < Admin::ApplicationController
  respond_to :html

  before_action :load_page, only: %i(show edit update destroy toggle move_up move_down)
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
    @pages = Page.with_translations
    respond_with :admin, @pages
  end

  def new
    @page = Page.new(parent: @parent_page)   
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
    #@page.embeddable.translations.each do |t|
    #  t.regions.build
    #end
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

  def toggle
    attribute = params[:attribute]
    respond_to do |format|
      format.html do
        if attribute.in? %w(published menu_item)
          @page.update_column(attribute, !@page.attributes[attribute])
          redirect_to request.referer || [:admin, @page]
        else
          head :not_found
        end
      end
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

  def preview_path
    @page = Page.new(params.symbolize_keys.slice(:slug, :parent_id))
    @page.valid?
    respond_to do |format|
      format.html { render text: @page.slug.present? ? File.join(request.host, @page.path) : '' }
    end
  end

  def embeddable_fields
    @page = Page.new(embeddable_type: params.fetch(:embeddable_type), embeddable_id: params[:embeddable_id])
    respond_to do |format|
      format.html do
        if @page.embeddable_class
          if @page.embeddable.nil?
            @page.embeddable = @page.embeddable_class.new
            if @page.embeddable.class.reflect_on_association(:translations)
              @page.embeddable.translations.build(locale: I18n.locale)
            end
          end
          render layout: false
        else
          head :not_found
        end
      end
    end
  end

  def embeddable_settings
    @page = Page.new(embeddable_type: params.fetch(:embeddable_type))
    respond_to do |format|
      format.html do
        if @page.embeddable_class
          @page.embeddable = @page.embeddable_class.new
          if @page.embeddable.class.reflect_on_association(:translations)
            @page.embeddable.translations.build(locale: I18n.locale)
          end
          render layout: false
        else
          head :not_found
        end
      end
    end
  end

  def translation_fields
    translated_locale = params.fetch(:translated_locale)
    @page = Page.new(embeddable_type: params.fetch(:embeddable_type))
    respond_to do |format|
      format.html do
        if @page.embeddable_class and translated_locale.in?(I18n.available_locales.map(&:to_s))
          @page.embeddable = @page.embeddable_class.new
          @page.embeddable.translations.build(locale: translated_locale)
          render "admin/#{@page.embeddable_type.underscore.pluralize}/translation_fields", layout: false 
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
    when 'Content' then [:id, { translations_attributes: [:_destroy, :id, :locale, :title, :content] }]
    when 'Gallery' then [:id, { translations_attributes: [:_destroy, :id, :locale, :title, :description] }]
    when 'Image' then [:id, :asset, { translations_attributes: [:_destroy, :id, :locale, :title, :description] }]
    when 'Redirection' then [:id, :external, :destination_page_id, :destination_url, :permanent, { translations_attributes: [:_destroy, :id, :locale, :title, :description] }]
    end
    page_params.permit(:embeddable_id, :embeddable_type, :slug, :parent_id, :published, :menu_item, :template_id, embeddable_attributes: embeddable_attributes_params || {}) 
  end
end