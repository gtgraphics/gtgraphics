class PagesController < ApplicationController
  respond_to :html

  before_action :load_page

  helper_method :page

  breadcrumbs do |b|
    @page.self_and_ancestors.published.each do |page|
      b.append page.title, page
    end
  end

  class << self
    def load_embedded(resource_name)
      helper_method resource_name.to_sym
      before_action do
        instance_variable_set("@#{resource_name}", @page.embeddable)
      end
    end
  end

  def show
    respond_with_page
  end

  protected
  def render_page(options = {})
    render @page.template_path, options
  end

  def respond_with_page(options = {})
    respond_with @page, options.merge(template: @page.template_path)
  end

  private
  def load_page
    if params[:id].blank?
      @page = Page.published.root
    else
      @page = Page.published.find_by_path!(params[:id])
    end
  end
end