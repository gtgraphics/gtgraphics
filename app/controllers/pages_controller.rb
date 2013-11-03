class PagesController < ApplicationController
  respond_to :html

  before_action :load_page
  helper_method :page

  breadcrumbs do |b|
    @page.self_and_ancestors.published.each do |page|
      b.append page.title, page
    end
  end

  def show
    respond_with @page, template: @page.template_path
  end

  private
  def load_page
    @page = Page.published.find_by_path!(params[:id] || '')
  end
end