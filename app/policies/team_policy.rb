class TeamPolicy < ApplicationPolicy
  attr_reader :user, :team

  def initialize(user, team)
    @user = user
    @team = team
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    (!user.student? or !user.has_team_for_season?) and (Submissions.closing_date > Date.today)
  end

  def edit?
    member? and Submissions.open?
  end

  def update?
    member?
  end

  def event_signup?
    member?
  end

  def edit_submission?
    member? and Submissions.open?
  end

  def join?
    !user.team_requests.exists?(team: team)
  end

  def submit?
    member?
  end

  def leave?
    member?
  end

  def destroy?
    false
  end

  # def update_submissions?
  #   member?
  # end

  private
  def member?
    team.members.include? user
  end

end
