json.records do
  json.array! @tags, partial: 'tag', as: :tag
end
if @tags.respond_to?(:last_page?)
  json.more !@tags.last_page?
else
  json.more false
end
