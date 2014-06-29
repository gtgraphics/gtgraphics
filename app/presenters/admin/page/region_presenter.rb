class Admin::Page::RegionPresenter < Admin::ApplicationPresenter
  presents :region

  self.action_buttons -= [:show] 

  def show_path
    h.admin_page_region_path(region.page, region)
  end

  def edit_path
    h.edit_admin_page_region_path(region.page, region)
  end
end