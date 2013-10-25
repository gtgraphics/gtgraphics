class Admin::GalleriesController < Admin::ApplicationController
  respond_to :html

  before_action :load_gallery, only: %i(show edit update destroy)

  breadcrumbs do |b|
    b.append Gallery.model_name.human(count: 2), :admin_galleries
    b.append translate('breadcrumbs.new', model: Gallery.model_name.human), :new_admin_gallery if action_name.in? %w(new create)
    b.append @gallery.title, [:admin, @gallery] if action_name.in? %w(show edit update)
    b.append translate('breadcrumbs.edit', model: Gallery.model_name.human), [:edit, :admin, @gallery] if action_name.in? %w(edit update)
  end

  def index
    @galleries = Gallery.with_translations(I18n.locale).order(Gallery::Translation.arel_table[:name])
    respond_with :admin, @galleries
  end

  def new
    @gallery = Gallery.new
    @gallery.translations.build(locale: I18n.locale)
    respond_with :admin, @gallery
  end

  def create
    @gallery = Gallery.create(gallery_params)
    respond_with :admin, @gallery
  end

  def edit
    respond_with :admin, @gallery
  end

  def update
    @gallery.update(gallery_params)
    respond_with :admin, @gallery
  end

  def destroy
    @gallery.destroy
    respond_with :admin, @gallery
  end

  def translation_fields
    respond_to do |format|
      format.html
    end
  end

  def translation_fields
    translated_locale = params.fetch(:translated_locale)
    @gallery = Gallery.new
    @gallery.translations.build(locale: translated_locale)
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
  def gallery_params
    params.require(:gallery).permit! # TODO
  end

  def load_gallery
    @gallery = Gallery.find(params[:id])
  end
end