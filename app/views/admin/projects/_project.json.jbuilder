json.extract! project, :id, :title
json.client_name project.client_name
json.url admin_project_path(project)
if image = project.images.first
  json.thumbnail_asset_url image.asset.thumbnail.url
end