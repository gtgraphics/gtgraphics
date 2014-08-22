json.projects do
  json.array! @projects, partial: 'project', as: :project
end
json.page @projects.current_page
json.total_pages @projects.total_pages
json.more !@projects.last_page?