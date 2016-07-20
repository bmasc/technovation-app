require "rails_helper"

RSpec.feature "Regional Ambassadors registration" do
  before do
    visit signup_path
    click_link "Regional Ambassador sign up"

    fill_in "First name", with: "Regional"
    fill_in "Last name", with: "McGee"

    select_date Date.today - 31.years, from: "Date of birth"

    select "United States", from: "Country"
    fill_in "State / Province", with: "IL"
    fill_in "City", with: "Chicago"

    fill_in "Organization/company name", with: "John Hughes Inc."
    fill_in "Since what year have you been a regional ambassador?", with: 2016

    fill_in "Email", with: "regional@ambassador.com"
    fill_in "Password", with: "secret1234"
    fill_in "Confirm password", with: "secret1234"

    click_button "Sign up"
  end

  scenario "redirects to dashboard" do
    expect(current_path).to eq(regional_ambassador_dashboard_path)
  end

  scenario "displays a pending approval notice" do
    expect(page).to have_content("Thank you for registering as a Regional Ambassador. Technovation staff will review your account shortly to ensure that your information is correct. Once you are confirmed, you will have access to student data in your region.")
  end
end
