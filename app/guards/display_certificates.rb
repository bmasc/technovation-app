module DisplayCertificates
  def self.for(judge)
    SeasonToggles.display_scores? &&
      judge.current_complete_scores.any?
  end
end