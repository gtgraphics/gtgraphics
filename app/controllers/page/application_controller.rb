class Page
  class ApplicationController < ::ApplicationController
    respond_to :html

    before_action :load_page
    before_action :load_template
    before_action :track_hit

    attr_reader :page
    protected :page
    helper_method :page, :template_file

    breadcrumbs do |b|
      pages = @page.self_and_ancestors.accessible_by(current_ability)
              .with_translations_for_current_locale
      pages.each do |page|
        b.append page.title, page
      end
    end

    def show
      respond_with_page
    end

    private

    # Rendering

    def render_page(options = {})
      render template_path, options
    end

    def respond_with_page
      respond_to do |format|
        format.html { render_page }
        yield(format) if block_given?
      end
    end

    def template_file
      @page.check_template_support!
      @template.filename.inquiry
    end

    def template_path
      File.join(@page.embeddable_type.underscore.pluralize,
                'templates', template_file)
    end

    # Filters

    def load_page
      @page = current_page
      return @page if can?(:read, @page)
      fail ActionController::RoutingError, 'Page is invisible'
    end

    def load_template
      return unless current_page.support_templates?
      @template = current_page.template
      @region_definitions = @template.region_definitions
    end

    def load_menu_items
      @menu_items = Page.primary.published.menu_items
                    .accessible_by(current_ability)
                    .with_translations_for_current_locale
    end

    def track_hit
      @page.track_visit! if current_subroute.nil?
    end

    # Helpers

    def localized_request_url(locale)
      params = request.query_parameters.merge(locale: locale)
      current_page_path(params)
    end
  end
end
