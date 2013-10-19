class Admin::MenuItemsController < Admin::ApplicationController
  respond_to :html

  before_action :load_menu_item, only: %i(show edit update destroy)
  before_action :load_parent_menu_item, only: %i(new create show edit update)

  #breadcrumbs_for_resource
  breadcrumbs do |b|
    b.append MenuItem.model_name.human(count: 2), :admin_menu_items
    b.append translate('breadcrumbs.new', model: MenuItem.model_name.human), :new_admin_menu_item if action_name.in? %w(new create)
    b.append translate('breadcrumbs.edit', model: MenuItem.model_name.human), [:edit, :admin, @menu_item] if action_name.in? %w(edit update)
  end

  def index
    @menu_items = MenuItem.roots
    respond_with :admin, @menu_items
  end

  def new
    @menu_item = MenuItem.new
    @menu_item.translations.build(locale: I18n.default_locale)
    #@menu_item.build_translations_for_available_locales
    respond_with :admin, @menu_item
  end

  def create
    @menu_item = MenuItem.create(menu_item_params)
    respond_with :admin, @menu_item, location: :admin_menu_items
  end

  def show
    respond_with :admin, @menu_item
  end

  def edit
    respond_with :admin, @menu_item
  end

  def update
    @menu_item.update(menu_item_params)
    respond_with :admin, @menu_item, location: :admin_menu_items
  end

  def destroy
    @menu_item.destroy
    respond_with :admin, @menu_item
  end

  def record_type_fields
    @menu_item = MenuItem.new(record_type: params.fetch(:record_type))
    respond_to do |format|
      format.html { render layout: false }
    end    
  end

  def translation_fields
    translated_locale = params.fetch(:translated_locale)
    @menu_item = MenuItem.new
    @menu_item.translations.build(locale: translated_locale)
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
  def load_menu_item
    @menu_item = MenuItem.find(params[:id])
  end

  def load_parent_menu_item
    if parent_id = params[:parent_id]
      @parent_menu_item = MenuItem.find_by_id(parent_id)
    elsif menu_item_params = params[:menu_item]
      @parent_menu_item = MenuItem.find_by_id(menu_item_params[:parent_id])
    elsif @page
      @parent_menu_item = @page.parent
    end
  end

  def menu_item_params
    params.require(:menu_item).permit(:target_type, :target_id, :new_window, translations_attributes: [:_destroy, :id, :locale, :title])
  end
end