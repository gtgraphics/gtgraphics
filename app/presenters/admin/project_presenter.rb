class Admin::ProjectPresenter < Admin::ApplicationPresenter
  presents :project
  
  def author
    present project.author, with: Admin::UserPresenter 
  end

  def released_in
    super.presence || placeholder
  end

  def client
    client_name.presence || placeholder
  end

  def summary
    human_name = Image.model_name.human(count: project.images_count)
    "#{project.images_count} #{human_name}"
  end
end