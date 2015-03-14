class Admin::User::SocialLinksController < Admin::ApplicationController
  respond_to :html

  before_action :load_user
  before_action :load_social_link, only: %i(edit update destroy
                                            move_up move_down)

  breadcrumbs do |b|
    b.append User.model_name.human(count: 2), :admin_users
    b.append @user.name, [:admin, @user]
    b.append User::SocialLink.model_name.human(count: 2),
             [:admin, @user, :social_links]
    if action_name.in? %w(new create)
      b.append translate('breadcrumbs.new', model: User::SocialLink.model_name.human),
               [:new, :admin, @user, @social_link]
    end
    if action_name.in? %w(edit update)
      b.append translate('breadcrumbs.edit', model: User::SocialLink.model_name.human),
               edit_admin_user_social_link_path(@user, @social_link)
    end
  end

  def index
    @networks = @user.social_links.networks.preload(:provider)
    @shops = @user.social_links.shops.preload(:provider)

    respond_to do |format|
      format.html
    end
  end

  def new
    @social_link = @user.social_links.new

    respond_with :admin, @user, @social_link
  end

  def create
    @social_link = @user.social_links.create(social_link_params)

    respond_with :admin, @user, @social_link,
                 location: [:admin, @user, :social_links]
  end

  def edit
    respond_with :admin, @user, @social_link
  end

  def update
    @social_link.update(social_link_params)

    respond_with :admin, @user, @social_link,
                 location: [:admin, @user, :social_links]
  end

  def destroy
    @social_link.destroy

    respond_with :admin, @user, @social_link,
                 location: [:admin, @user, :social_links]
  end

  def move_up
    @social_link.move_higher

    respond_with :admin, @user, @social_link,
                 location: [:admin, @user, :social_links]
  end

  def move_down
    @social_link.move_lower

    respond_with :admin, @user, @social_link,
                 location: [:admin, @user, :social_links]
  end

  private

  def load_user
    @user = User.find(params[:user_id])
  end

  def load_social_link
    @social_link = @user.social_links.find(params[:id])
  end

  def social_link_params
    params.require(:social_link).permit(:provider_id, :url, :shop)
  end
end
