class Ability
  include CanCan::Ability

  attr_reader :user

  def initialize(user)
    @user = user
    declare

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end

  def declare
    # Guests
    can :create, Message
    can :read, Page, published: true

    if user
      # Admins
      can [:read, :destroy], Message, Message.joins(:recipients)
        .where(users: { id: user.id }) do |message|
        message.recipient_ids.include?(user.id)
      end

      can :manage, Attachment
      can :manage, [Image, Image::Style, Image::Attachment]
      can :manage, [Project, Project::Image]

      can [:read, :create, :update], Page
      can :destroy, Page, Page.where.not(parent_id: nil) do |page|
        page.destroyable?
      end
      Page.embeddable_classes.each do |embeddable_class|
        can [:read, :update], embeddable_class
        can :create, embeddable_class, &:creatable?
      end
      can :manage, Page::Region

      can :manage, [Template, Template::RegionDefinition]
      can :manage, User
      can :manage, Provider
      can :manage, User::SocialLink
    end
  end
end
