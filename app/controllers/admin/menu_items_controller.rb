class Admin::MenuItemsController < Admin::ApplicationController
  respond_to :html

  before_action :load_menu_item, only: %i(show edit update destroy)

  breadcrumbs_for_resource

  def index
    @menu_items = MenuItem.all
    respond_with :admin, @menu_items
  end

  def new
    @menu_item = MenuItem.new
    @menu_item.build_translations_for_available_locales
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

  private
  def load_menu_item
    @menu_item = MenuItem.find(params[:id])
  end

  def menu_item_params
    params.require(:menu_item).permit! # FIXME
  end
end