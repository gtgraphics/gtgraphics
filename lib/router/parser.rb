module Router
  class Parser
    DEFAULT_FORMAT = 'html'

    attr_reader :request_path, :request_method

    def initialize(request_path, request_method)
      @request_path = Path.normalize(request_path)
      @request_method = request_method.to_s.downcase
    end

    def page
      @page ||= begin
        conditions = []

        base_condition = Page.arel_table[:path].eq(request_path)
        base_condition = base_condition.and(
          Page.arel_table[:embeddable_type].not_in(matching_subroutes.keys)
        ) if matching_subroutes.any?

        conditions << base_condition
        conditions += matching_subroutes.collect do |page_type, subroute|
          Page.arel_table[:path].eq(subroute[:path])
          .and(Page.arel_table[:embeddable_type].eq(page_type))
        end

        Page.find_by(conditions.reduce(:or))
      end
    end

    def locale
      path_parts[:locale]
    end

    def format
      path_parts[:format]
    end

    def fullpath
      path_parts[:path]
    end

    def path
      subroute_info ? subroute_info[:path] : fullpath
    end

    def subpath
      subroute_info[:subpath] if subroute_info
    end

    def path_parameters
      return {}.with_indifferent_access if subroute_info.nil?
      subroute_info[:params].with_indifferent_access
    end

    def subroute
      subroute_info[:definition] if subroute_info
    end

    private

    # Subroutes

    def subroute_info
      matching_subroutes[page.embeddable_type]
    end

    def matching_subroutes
      @matching_subroutes ||= begin
        Page::EMBEDDABLE_TYPES.each_with_object({}) do |page_type, subroutes|
          controller_class = "#{page_type.pluralize}Controller".safe_constantize
          next if controller_class.nil?
          result = nil
          controller_class.subroutes.each do |subroute|
            params = subroute.match(fullpath, request_method)
            next if params.nil?
            subpath = Path.normalize(fullpath.sub(/\A#{Regexp.escape(params[:path].to_s)}/, ''))
            result = { definition: subroute, path: params[:path],
                       subpath: subpath, params: params.except(:path) }
            break
          end
          subroutes[page_type] = result if result
        end
      end
    end

    # Path Preparation

    def path_parts
      @path_parts ||= begin
        path = request_path
        slugs = path.split(File::SEPARATOR)
        locale = slugs.shift
        if valid_locale?(locale)
          path = slugs.join(File::SEPARATOR)
        else
          locale = nil
        end
        format = extract_format!(path)
        { locale: locale, path: path, format: format }
      end
    end

    def valid_locale?(locale)
      return false if locale.blank?
      locale.length == 2 && @available_locales.include?(locale)
    end

    def extract_format!(path)
      format = path.match(/\.(.*)\z/).try(:captures).try(:first)
      path.sub!(/\.#{Regexp.escape(format)}\z/, '') if format
      format || DEFAULT_FORMAT
    end
  end
end
