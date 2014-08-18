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
end