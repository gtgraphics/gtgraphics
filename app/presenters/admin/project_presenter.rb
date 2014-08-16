class Admin::ProjectPresenter < Admin::ApplicationPresenter
  presents :project
  
  def author
    present project.author, with: Admin::UserPresenter 
  end  
end