class RenameFacebookCommentsUriToFacebookUriInImagePages < ActiveRecord::Migration
  def change
    rename_column :image_pages, :facebook_comments_uri, :facebook_uri
  end
end
