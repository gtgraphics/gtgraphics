class Page
  module PaginationHelper
    def pagination_link_tags(relation)
      capture do
        if relation.current_page > 1
          prev_url =
            paginated_url_for_current_page(page: relation.current_page - 1)
          concat tag(:link, rel: 'prev', href: prev_url)
        end
        if relation.current_page < relation.total_pages
          next_url =
            paginated_url_for_current_page(page: relation.current_page.next)
          concat tag(:link, rel: 'next', href: next_url)
        end
      end
    end

    def paginated_url_for_current_page(*args)
      options = args.extract_options!.reverse_merge(params.permit!.to_h)
      subroute = args.first || current_subroute.try(:name)
      page = options[:page].to_i
      options.delete(:page) if page <= 1
      current_page_url(subroute, options)
    end
  end
end
