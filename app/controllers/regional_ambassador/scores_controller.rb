require "will_paginate/array"

module RegionalAmbassador
  class ScoresController < RegionalAmbassadorController
    def index
      params[:page] ||= 1
      params[:per_page] ||= 15

      @division = params[:division] ||= "senior"

      events = RegionalPitchEvent.in_region_of(current_ambassador)
      virtual_event = Team::VirtualRegionalPitchEvent.new

      if virtual_event.teams.for_ambassador(current_ambassador).any?
        params[:evemt] ||= "virtual"

        @event = if params[:event] == "virtual"
                  virtual_event
                else
                  events.eager_load(teams: { team_submissions: :submission_scores })
                        .find(params[:event])
                end

        @events = [virtual_event] + events.sort_by(&:name)
      else
        params[:event] ||= events.pluck(:id).sort.first

        @event = events.eager_load(teams: { team_submissions: :submission_scores })
                       .find(params[:event])

        @events = events.sort_by(&:name)
      end

      @teams = get_sorted_paginated_teams_in_requested_division
    end

    def show
      @team_submission = TeamSubmission.includes(
        team: :division,
        submission_scores: { judge_profile: :account }
      ).friendly.find(params[:id])

      @team = @team_submission.team

      @event = @team.selected_regional_pitch_event

      @scores = @team_submission.submission_scores
        .complete
        .includes(judge_profile: :account)
        .references(:accounts)
        .order("accounts.first_name")
    end

    private
    def get_sorted_paginated_teams_in_requested_division(page = params[:page])
      teams = @event.teams
        .for_ambassador(current_ambassador)
        .public_send(params[:division])
        .sort { |a, b|
          case params.fetch(:sort) { "avg_score_desc" }
          when "avg_score_desc"
            b.submission.average_score <=> a.submission.average_score
          when "avg_score_asc"
            a.submission.average_score <=> b.submission.average_score
          when "team_name"
            a.name <=> b.name
          end
        }.paginate(page: page.to_i, per_page: params[:per_page].to_i)

      if teams.empty? and page.to_i != 1
        get_sorted_paginated_teams_in_requested_division(1)
      else
        teams
      end
    end
  end
end
