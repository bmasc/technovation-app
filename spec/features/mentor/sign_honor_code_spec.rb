require "rails_helper"

RSpec.feature "Mentors sign the honor code" do
  scenario "existing mentor is interrupted to sign it" do
    mentor = FactoryGirl.create(:mentor)
    mentor.void_honor_code_agreement!

    sign_in(mentor)
    visit new_mentor_team_path
    click_link "Sign the Technovation Honor Code"

    expect(page).to have_content("you promise that all elements of your #{Season.current.year} Technovation submission")

    check "I agree to the statement above"
    fill_in "Electronic signature", with: "Agreement Duck"
    click_button "Agree"

    expect(mentor.reload.honor_code_signed?).to be true
    expect(HonorCodeAgreement.last.account_id).to eq(mentor.account_id)
  end

  scenario "existing mentor doesn't sign it correctly" do
    mentor = FactoryGirl.create(:mentor)
    mentor.void_honor_code_agreement!

    sign_in(mentor)
    visit new_mentor_team_path
    click_link "Sign the Technovation Honor Code"

    fill_in "Electronic signature", with: "Agreement Duck"
    click_button "Agree"

    expect(page).to have_content("must be checked")

    check "I agree to the statement above"
    fill_in "Electronic signature", with: ""
    click_button "Agree"

    expect(page).to have_content("can't be blank")
  end

  %w{student mentor}.each do |type|
    scenario "an invalid #{type} profile without an honor code agreement is interrupted" do
      profile = FactoryGirl.create(type)

      profile.account.update_columns(latitude: nil, longitude: nil, city: nil, state_province: nil)
      profile.account.honor_code_agreement.destroy
      profile.reload.account.geocoded = nil

      expect(profile).not_to be_valid
      expect(profile.honor_code_agreement).to be_nil

      sign_in(profile)
      expect(page).to have_current_path(interruptions_path(issue: :invalid_profile))

      click_link "Fix my profile now"

      within(".#{profile.type_name.underscore}_profile_account_geocoded") do
        expect(page).to have_css('.error', text: "can't be blank")
      end

      sign_out
    end
  end
end
