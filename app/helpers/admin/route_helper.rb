module Admin::RouteHelper
  def typed_new_admin_page_path(parent_page, embeddable_class)
    element_name = embeddable_class.model_name.element
    if respond_to? "new_admin_page_#{element_name}_path"
      send("new_admin_page_#{element_name}_path", @page)
    else
      typed_new_admin_page_child_path(@page, page_type: element_name)
    end
  end
end