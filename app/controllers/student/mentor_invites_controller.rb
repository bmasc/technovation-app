module Student
  class MentorInvitesController < StudentController
    def create
      @mentor_invite = MentorInvite.new(mentor_invite_params)

      if @mentor_invite.save
        redirect_to [:student, @mentor_invite.team],
          success: t("controllers.team_member_invites.create.success")
      else
        redirect_to :back, alert: t("views.application.general_error")
      end
    end

    def destroy
      @invite = current_student.team.mentor_invites.find_by(invite_token: params.fetch(:id))
      @invite.destroy
      redirect_to :back, success: t("controllers.invites.destroy.success", name: @invite.invitee_name)
    end

    private
    def mentor_invite_params
      params.require(:mentor_invite).permit(:invitee_email).tap do |params|
        params[:inviter_id] = current_student.id
        params[:team_id] = current_student.team_id
      end
    end
  end
end
