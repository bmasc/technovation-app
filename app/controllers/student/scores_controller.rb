module Student
  class ScoresController < StudentController
    def index
      @all_scores = SubmissionScore.none
      @quarterfinals_scores = SubmissionScore.none
      @semifinals_scores = SubmissionScore.none

      if current_team.submission.present? and SeasonToggles.display_scores?
        @all_scores = current_team.submission.submission_scores.complete
        @quarterfinals_scores = @all_scores.quarterfinals

        if current_team.submission.semifinalist?
          @semifinals_scores = @all_scores.semifinals
        end
      end

      @certificates = Certificate.none

      if SeasonToggles.display_scores?
        # todo: check if the certificate exists
        #   if it does not exist, then do the following:
        #   determine the certificate type - do students only get 1 type of certificate? (I think yes)
        #   generate that type of certificate
        #   else:
        #   get the current certificate and return that



        if current_account.certificates.current.empty?
          puts '*********************** '
          puts '*********************** no certificate#!!!!!!!'
          puts '*********************** '

          certificate_recipient = CertificateRecipient.new('participation', current_account, team: current_team)
          @certificates = CertificateJob.perform_now(certificate_recipient.state)
        else
          puts '*********************** '
          puts '*********************** there is a certificate! yay'
          puts '*********************** '

          @certificates = current_account.certificates.current
        end
      end

      render template: 'student/scores/index'
    end
  end
end