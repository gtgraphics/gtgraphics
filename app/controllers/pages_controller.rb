class PagesController < ApplicationController
  respond_to :html

  # before_action :set_translation_locale
  before_action :load_page
  before_action :load_template

  authorize_resource class: 'Page', parent: false, only: :edit

  attr_reader :page
  protected :page
  helper_method :page

  breadcrumbs do |b|
    @page.self_and_ancestors.accessible_by(current_ability).with_translations.each do |page|
      b.append page.title, page
    end
  end

  class << self
    def embeds(embeddable_name)
      method_name = embeddable_name.to_sym

      helper_method method_name
      attr_reader method_name
      protected method_name

      before_action do
        instance_variable_set("@#{embeddable_name}", @page.embeddable)
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
    unless @page.embeddable_class.support_templates?
      raise ActionView::MissingTemplate, "#{@page.embeddable_class} does not support templates"
    end
    respond_with @page, options.merge(template: @page.template_path)
  end

  private
  def load_page
    if params[:path].blank?
      @page = Page.accessible_by(current_ability).roots.first!
    else
      @page = Page.accessible_by(current_ability).find_by!(path: params[:path])
    end
  end

  def load_template
    if @page.support_templates?
      @template = @page.template 
      @region_definitions = @template.try(:region_definitions)
    end
  end
end