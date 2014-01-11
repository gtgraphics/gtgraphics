module SortHelper
  def sort_link_for(collection, column_name, *args, &block)
    options = args.extract_options!
    
    options[:class] ||= ''
    options[:class] << ' sort-link'
    options[:class] << " sorted sorted-#{collection.sort_direction.to_sym}" if collection.sorted_by?(column_name)
    options[:class].strip!

    caption = block_given? ? capture(&block) : args.first
    caption = collection.klass.human_attribute_name(column_name) if caption.nil?

    direction = collection.sorted_by?(column_name) ? collection.sort_direction.invert.to_sym : Sortable::Direction.default.to_sym
    if column_name.to_s == collection.default_sort_column and direction == Sortable::Direction.default.to_sym
      url = url_for(sort: nil, direction: nil) # default order
    else
      url = url_for(sort: column_name, direction: direction)
    end

    link_to url, options do
      concat content_tag(:span, caption, class: 'sort-caption')
      if collection.sorted_by?(column_name)
        concat content_tag(:span, icon(:caret, direction: collection.sort_direction.descending? ? :down : :up), class: 'sort-indicator')
      end
    end
  end
end