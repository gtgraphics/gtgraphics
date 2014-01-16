class PagesController < ApplicationController
  respond_to :html

  before_action :load_page

  attr_reader :page
  protected :page
  helper_method :page

  breadcrumbs do |b|
    @page.self_and_ancestors.published.each do |page|
      b.append page.title, page
    end
  end

  class << self
    def embeds(resource_name)
      helper_method resource_name.to_sym
      attr_reader resource_name.to_sym
      protected resource_name.to_sym

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
    unless @page.embeddable_class.supports_template?
      raise ActionView::MissingTemplate, "#{@page.embeddable_class} does not support templates"
    end
    respond_with @page, options.merge(template: @page.template_path)
  end

  private
  def load_page
    if params[:path].blank?
      @page = Page.accessible_by(current_ability).root
    else
      @page = Page.accessible_by(current_ability).find_by_path!(params[:path])
    end
  end
end