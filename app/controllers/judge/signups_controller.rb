module Judge
  class SignupsController < ApplicationController
    def new
      if token = get_cookie(:signup_token)
        setup_valid_profile_from_signup_attempt(:judge, token)
      elsif token = params[:admin_permission_token]
        setup_valid_profile_from_invitation(:judge, token)
      else
        redirect_to root_path
      end
    end

    def create
      @judge_profile = JudgeProfile.new(judge_profile_params)

      if @judge_profile.save
        ProfileCreating.execute(@judge_profile, self, :judge)
      else
        render :new
      end
    end

    private
    def judge_profile_params
      params.require(:judge_profile).permit(
        :company_name,
        :job_title,
        account_attributes: [
          :id,
          :email,
          :password,
          :date_of_birth,
          :first_name,
          :last_name,
          :gender,
          :geocoded,
          :city,
          :state_province,
          :country,
          :latitude,
          :longitude,
          :referred_by,
          :referred_by_other,
        ],
      ).tap do |tapped|
        attempt =
          SignupAttempt.find_by(signup_token: get_cookie(:signup_token)) ||
            UserInvitation.find_by!(
              admin_permission_token: get_cookie(:admin_permission_token)
            )

        tapped[:account_attributes][:email] = attempt.email

        unless attempt.temporary_password?
          tapped[:account_attributes][:password_digest] = attempt.password_digest
        end
      end
    end
  end
end
