class PagesController < ApplicationController
  respond_to :html

  with_options only: :show do |controller|
    controller.before_action :load_page
    
    controller.breadcrumbs do |b|
      @page.self_and_ancestors.each do |page|
        b.append page.title, page
      end
    end
  end

  def index
    respond_to do |format|
      format.html
    end
  end

  def show
    respond_with @page, template: @page.template_path
  end

  private
  def load_page
    @page = Page.find_by_path!(params[:id])
  end
end