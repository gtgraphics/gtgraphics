module Admin::RouteHelper
  def admin_page_editor_path(*args)
    options = args.extract_options!
    if page = args.first
      page_path_options = options.delete(:page) { Hash.new }
      path = page_path(page, page_path_options).sub(/\A\//, '') # strip leading slash
      options.merge!(path: path)
    end
    super(options)
  end
end