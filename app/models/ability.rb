class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
    else
      if user.country == 'US'
        if user.state?
          can :read, User, :home_country => user.country, :home_state => user.state
          can :read, Team, :country => user.country, :state => user.state
        else
          can :read, User, :home_country => user.country
          can :read, Team, :country => user.country
        end
      else
        if user.country?
          can :read, User, :home_country => user.country
          can :read, Team, :country => user.country
        else
          can :read, User
          can :read, Team
        end
      end
      can :read, ActiveAdmin::Page, :name => 'Dashboard'
    end
  end
end