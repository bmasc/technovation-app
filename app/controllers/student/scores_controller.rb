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
        if current_account.certificates.current.empty?
          @needed_certificates = DetermineCertificates.new(current_account).needed
          @certificate_type = @needed_certificates[0].certificate_type

          certificate_recipient = CertificateRecipient.new(@certificate_type, current_account, team: current_team)
          @certificates = CertificateJob.perform_now(certificate_recipient.state)
        else
          @certificates = current_account.certificates.current
        end
      end

      render template: 'student/scores/index'
    end
  end
end