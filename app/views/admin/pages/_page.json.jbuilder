json.extract! page, :id, :title, :parent_id, :depth
json.type page.embeddable_class.model_name.human
json.path page.path
json.href page_path(page)