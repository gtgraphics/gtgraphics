module Router
  class Parser
    DEFAULT_REQUEST_METHODS = %w(get head)
    IGNORED_PATHS = %w(assets)

    attr_reader :request_path, :request_method

    def self.from_env(env)
      new(env['REQUEST_PATH'], env['REQUEST_METHOD'])
    end

    def initialize(request_path, request_method)
      @request_path = Path.normalize(request_path)
      @request_method = request_method.to_s.downcase
    end

    def page
      @page ||= begin
        conditions = []

        base_condition = Page.arel_table[:path].eq(fullpath)
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

    def controller
      infer_controller_class(page.embeddable_type)
    end

    def action
      action = nil
      if subroute
        action ||= subroute.action.try(:to_sym)
        action ||= subroute.path.to_sym if action_exists?(subroute.path)
      end
      template_file = page.template.try(:file_name)
      action ||= template_file.to_sym if action_exists?(template_file)
      action || :show
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
      return ActiveSupport::HashWithIndifferentAccess.new if subroute_info.nil?
      subroute_info[:params].with_indifferent_access
    end

    def subroute
      subroute_info[:definition] if subroute_info
    end

    # Request Validation

    def invalid_request?
      request_ignored? || !valid_request_method? || page.nil? || controller.nil?
    end

    def request_ignored?
      IGNORED_PATHS.any? do |ignored_path|
        request_path.start_with?(ignored_path)
      end
    end

    def allowed_request_methods
      return DEFAULT_REQUEST_METHODS if subroute.nil?
      subroute.request_methods
    end

    def valid_request_method?
      allowed_request_methods.include?(request_method)
    end

    private

    def action_exists?(name)
      return false if name.blank?
      controller.action_methods.include?(name.to_s)
    end

    def infer_controller_class(page_type)
      "#{page_type.to_s.pluralize}Controller".safe_constantize
    end

    # Subroutes

    def subroute_info
      matching_subroutes[page.embeddable_type] if page
    end

    def matching_subroutes
      @matching_subroutes ||= begin
        Page::EMBEDDABLE_TYPES.each_with_object({}) do |page_type, subroutes|
          controller_class = infer_controller_class(page_type)
          next if controller_class.nil?
          result = nil
          controller_class.subroutes.each do |subroute|
            params = subroute.match(fullpath, request_method)
            next if params.nil?
            subpath = Path.normalize(
              fullpath.sub(/\A#{Regexp.escape(params[:path].to_s)}/, '')
            )
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
        if LocaleConstraint.valid_locale?(locale)
          path = slugs.join(File::SEPARATOR)
        else
          locale = nil
        end
        format = extract_format!(path)
        { locale: locale, path: path, format: format }
      end
    end

    def extract_format!(path)
      format = path.match(/\.(.*)\z/).try(:captures).try(:first).try(:downcase)
      path.sub!(/\.#{Regexp.escape(format)}\z/, '') if format
      format || Path::DEFAULT_FORMAT
    end
  end
end
