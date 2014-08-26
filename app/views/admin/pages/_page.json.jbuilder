json.extract! page, :id, :title, :parent_id, :depth
json.type page.embeddable_class.model_name.human
json.path page.path
json.url admin_page_path(page)
json.href page_path(page, locale: Globalize.locale)
