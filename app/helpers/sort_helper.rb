module SortHelper
  def sort_link_for(collection, column_name, *args, &block)
    options = args.extract_options!
    
    options[:class] ||= ''
    options[:class] << ' sort-link'
    options[:class] << " sorted sorted-#{collection.sort_direction.to_sym}" if collection.sorted_by?(column_name)
    options[:class].strip!

    caption = block_given? ? capture(&block) : args.first
    caption = collection.klass.human_attribute_name(column_name) if caption.nil?

    link_to url_for(sort: column_name, direction: collection.sorted_by?(column_name) ? collection.sort_direction.invert.to_sym : Sortable::Direction.default.to_sym), options do
      concat content_tag(:span, caption, class: 'sort-caption')
      if collection.sorted_by?(column_name)
        concat content_tag(:span, icon(:caret, direction: collection.sort_direction.descending? ? :down : :up), class: 'sort-indicator')
      end
    end
  end
end