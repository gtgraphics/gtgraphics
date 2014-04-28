class Admin::Editor::PagesController < Admin::Editor::ApplicationController
  layout 'admin/page_editor'

  before_action :set_page_locale
  before_action :load_page

  def edit
    respond_to do |format|
      format.html
    end
  end

  def update
    @page.assign_regions(region_params, locale: @page_locale)
    saved = @page.save
    respond_to do |format|
      format.html { head saved ? :ok : :unprocessable_entity }
    end
  end

  private
  def load_page
    @page = Page.find(params[:id])
  end

  def region_params
    region_labels = @page.available_regions.map(&:to_sym)
    params.permit(*region_labels)
  end

  def set_page_locale
    @page_locale = params[:page_locale]
    redirect_to params.merge(page_locale: I18n.locale) if @page_locale.nil?
  end
end