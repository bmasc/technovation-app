class RubricsController < ApplicationController
  before_action :authenticate_user!

  def new
    @rubric = Rubric.new(team: Team.friendly.find(params[:team]))
    authorize @rubric
  end

  def show
    @rubric = Rubric.find(params[:id])
    authorize @rubric
  end

  def index
    select_judging_teams = SelectJudgingTeams.new(current_user)
    select_judging_teams.call

    @event = select_judging_teams.event
    @teams = select_judging_teams.teams
    @rubrics = current_user.rubrics.where("extract(year from created_at) = ?",
                                          Setting.year)
  end

  def edit
    @rubric = Rubric.find(params[:id])
    @team = @rubric.team # Why not use @rubric.team in the view?
    authorize @rubric
  end

  def update
    @rubric = Rubric.find(params[:id])
    authorize @rubric

    if @rubric.update(rubric_params)
      @rubric.user_id = current_user.id
      @rubric.save
      redirect_to :rubrics
    else
      redirect_to :back
    end
  end

  def create
    @rubric = Rubric.new(rubric_params)
    @rubric.team = Team.find(@rubric.team_id)
    @rubric.user_id = current_user.id

    authorize @rubric
    if @rubric.save
      redirect_to :rubrics
    else
      render :new
    end
  end

  private
  def rubric_params
    params.require(:rubric).permit(
      :team_id, :identify_problem, :address_problem, :functional,
      :external_resources, :match_features, :interface, :description,
      :market, :competition, :revenue, :branding, :launched, :pitch,
      :identify_problem_comment, :address_problem_comment,
      :functional_comment, :external_resources_comment,
      :match_features_comment, :interface_comment, :description_comment,
      :market_comment, :competition_comment, :revenue_comment,
      :branding_comment, :pitch_comment, :launched_comment
    )
  end
end
