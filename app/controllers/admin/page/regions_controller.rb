class Admin::Page::RegionsController < Admin::Page::ApplicationController
  rescue_from Template::NotSupported do |exception|
    respond_to do |format|
      format.html { redirect_to [:admin, @page], alert: translate }
      format.any { head :not_found }
    end
  end

  def index
    raise Template::NotSupported.new(@page) unless @page.supports_template?
    @regions = @page.regions
    respond_with :admin, @page, @regions
  end
end