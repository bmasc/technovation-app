require 'will_paginate/array'

module SearchTeams
  def self.call(filter)
    teams = Team.current

    if filter.nearby.present?
      miles = filter.nearby == "anywhere" ? 40_000 : 50
      nearby = filter.nearby == "anywhere" ? filter.user.address_details : filter.nearby

      account_ids = Account.near(nearby, miles).select(:id).map(&:id)

      student_teams = StudentProfile.where(account_id: account_ids).flat_map(&:teams)
      mentor_teams = MentorProfile.where(account_id: account_ids).flat_map(&:teams)
      teams = mentor_teams + student_teams
    end

    unless filter.text.blank?
      results = teams.search({
        query: {
          query_string: {
            query: "*#{filter.text}*"
          },
        },
        from: 0,
        size: 10_000
      }).results
      teams = teams.where(id: results.flat_map { |r| r._source.id })
    end

    divisions = Division.where(name: filter.division_enums)
    teams = teams.where(division: divisions)

    teams = case filter.spot_available
            when true
              teams.select { |t| t.spot_available? }
            else
              teams
            end

    teams = case filter.has_mentor
            when true
              teams.select { |t| t.mentors.any? }
            when false
              teams.select { |t| t.mentors.empty? }
            else
              teams
            end

    case filter.user.class.name
    when "StudentProfile"
      teams.select(&:accepting_student_requests?)
    when "MentorProfile"
      teams.select(&:accepting_mentor_requests?)
    else
      teams
    end
  end
end
