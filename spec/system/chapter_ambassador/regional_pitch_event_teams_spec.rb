require "rails_helper"

RSpec.describe "Regional Pitch Event Teams", :js do
  let(:chapter_ambassador) { FactoryBot.create(:chapter_ambassador, :approved)}

  context "when MANAGE_EVENTS is enabled" do
    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("MANAGE_EVENTS", any_args).and_return(true)
    end

    it "sucessfully adds a team to an event" do
      FactoryBot.create(:regional_pitch_event, ambassador: chapter_ambassador)
      FactoryBot.create(:team, :senior, :live_event_eligible, name: "A1 Team")
      expect(RegionalPitchEvent.count).to be_present
      expect(Team.count).to be_present

      sign_in(chapter_ambassador)

      click_link "Events"
      find("img[alt='edit teams']").click
      expect(page).to have_content("ADD TEAMS")

      click_button "Add teams"
      find("img[src*='check-circle-o.svg']").click
      click_button "Done"
      click_button "Save selected teams"

      within("table.attendee-list") do
        expect(page).to have_content "A1 Team"
      end
    end

    it "prevents adding a team that would go over the event's capacity" do
      event = FactoryBot.create(:regional_pitch_event, capacity: 1, ambassador: chapter_ambassador)
      team_squares = FactoryBot.create(:team, :senior, :live_event_eligible, name: "Team Squares")
      event.teams << team_squares
      FactoryBot.create(:team, :senior, :live_event_eligible, name: "Team Triangles")
      expect(RegionalPitchEvent.count).to be_present
      expect(Team.count).to be_present

      sign_in(chapter_ambassador)

      click_link "Events"
      find("img[alt='edit teams']").click
      expect(page).to have_content("ADD TEAMS")

      click_button "Add teams"
      all("img[src*='check-circle-o.svg']").each { |img| img.click }
      click_button "Done"

      within("table.attendee-list") do
        expect(page).to have_content "Team Squares"
        expect(page).not_to have_content "Team Triangles"
      end
    end

    it "successfully removes a team from an event" do
      team  = FactoryBot.create(:team, :senior, :live_event_eligible, name: "Team LMNO")
      event = FactoryBot.create(:regional_pitch_event, ambassador: chapter_ambassador)
      expect(RegionalPitchEvent.count).to be_present
      expect(Team.count).to be_present
      event.teams = [team]
      sign_in(chapter_ambassador)

      click_link "Events"
      find("img[alt='edit teams']").click

      within("table.attendee-list") do
        expect(page).to have_content "Team LMNO"
      end

      find("table.attendee-list td:first-child").hover
      find(".attendee-list__actions img[src*='remove.svg']").click
      click_button "Yes, remove this team"

      expect(page).to have_content "You removed Team LMNO"
    end
  end

  context "when MANAGE_EVENTS is disabled" do
    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("MANAGE_EVENTS", any_args).and_return(false)
    end

    it "does not display the 'Edit Teams' icon/link" do
      sign_in(chapter_ambassador)

      click_link "Events"
      expect(page).not_to have_css("img[alt='edit teams']")
    end
  end
end
