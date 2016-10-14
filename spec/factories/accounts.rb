FactoryGirl.define do
  factory :account do
    sequence(:email) { |n| "account#{n}@example.com" }
    password { "secret1234" }

    date_of_birth { Date.today - 31.years }
    first_name { "Factory" }
    last_name { "Account" }

    city "Chicago"
    state_province "IL"
    country "US"
    latitude 41.50196838
    longitude { -87.64051818 }
    geocoded { [city, state_province, Country[country].name].compact.join(', ') }

    type { "Account" }

    pre_survey_completed_at Time.current

    profile_image "exists?"

    season_ids { [Season.current.id] }

    after(:create) do |a|
      unless a.type == "StudentAccount"
        a.create_consent_waiver(FactoryGirl.attributes_for(:consent_waiver))
      end
    end

    after :create do |a|
      a.update_column(:profile_image, "foo/bar/baz.png")
    end
  end

  factory :student, aliases: [:student_account], parent: :account, class: 'StudentAccount' do
    type { "StudentAccount" }
    date_of_birth { Date.today - 15.years }

    before(:create) do |s|
      unless s.student_profile.present?
        s.build_student_profile(FactoryGirl.attributes_for(:student_profile))
      end
    end

    after(:create) do |s|
      unless s.parental_consent.present?
        s.create_parental_consent!(FactoryGirl.attributes_for(:parental_consent))
      end
    end

    trait :on_team do
      after(:create) do |s|
        team = FactoryGirl.create(:team, members_count: 0)
        FactoryGirl.create(:team_membership, member_type: "StudentAccount",
                                             member_id: s.id,
                                             joinable: team)
      end
    end

    trait :full_profile do
      before(:create) do |s|
        s.student_profile_attributes = {
          parent_guardian_email: "example@example.com",
          parent_guardian_name: "Parenty McGee",
          school_name: "My school",
        }
      end
    end
  end

  factory :mentor, aliases: [:mentor_account], parent: :account, class: 'MentorAccount' do
    type { "MentorAccount" }
    association(:background_check)

    before(:create) do |m|
      unless m.mentor_profile.present?
        m.build_mentor_profile(FactoryGirl.attributes_for(:mentor_profile))
      end
    end

    trait :with_expertises do
      after(:create) do |m|
        2.times do
          FactoryGirl.create(:expertise,
                             mentor_profile_ids: m.mentor_profile_id)
        end
      end
    end

    trait :on_team do
      after(:create) do |m|
        team = FactoryGirl.create(:team)
        FactoryGirl.create(:team_membership, member_type: "MentorAccount",
                                             member_id: m.id,
                                             joinable: team)
      end
    end
  end

  factory :regional_ambassador, parent: :account, class: 'RegionalAmbassadorAccount' do
    type { "RegionalAmbassadorAccount" }

    regional_ambassador_profile
    association(:background_check)

    trait :approved do
      after(:create) do |m|
        m.approved!
      end
    end
  end

  factory :judge, aliases: [:judge_account], parent: :account, class: 'JudgeAccount' do
    type { "JudgeAccount" }

    before(:create) do |j|
      unless j.judge_profile.present?
        j.build_judge_profile(FactoryGirl.attributes_for(:judge_profile))
      end
    end
  end
end
