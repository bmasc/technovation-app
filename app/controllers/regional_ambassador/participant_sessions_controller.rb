module RegionalAmbassador
  class ParticipantSessionsController < RegionalAmbassadorController
    def show
      participant = Account.in_region(current_ambassador).find(params[:id])
      participant.regenerate_session_token
      cookies[:session_token] = participant.session_token
      redirect_to send("#{participant.scope_name}_dashboard_path")
    end

    def destroy
      participant = Account.in_region(current_ambassador).find(params[:id])
      participant.regenerate_session_token
      cookies.delete(:session_token)
      redirect_to regional_ambassador_participant_path(participant)
    end
  end
end
