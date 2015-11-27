json.extract! attachment, :id, :title
json.asset_url attachment.asset.url
json.url admin_attachment_path(attachment)
