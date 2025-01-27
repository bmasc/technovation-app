require "rails_helper"

RSpec.describe "Parental consent", :js do
  it "handles invalid email" do
    student = FactoryBot.create(:onboarding_student)

    sign_in(student)
    fill_in "Parent or guardian's email", with: "no-work"

    click_button "Send the form"

    expect(page).to have_css(
      '.error',
      text: "does not appear to be an email address"
    )

    fill_in "Parent or guardian's email", with: "no-work@gmail.com."

    click_button "Send the form"

    expect(page).to have_css(
      '.error',
      text: "does not appear to be an email address"
    )
  end

  it "handles invalid tokens" do
    [{ }, { token: "bad" }].each do |bad_token_params|
      visit edit_parental_consent_path(bad_token_params)
      expect(current_path).to eq(root_path)
      expect(page).to have_content("Sorry, that consent token was invalid.")
    end
  end

  it "handles valid token, but an invalid signature form" do
    student = FactoryBot.create(:onboarding_student)

    visit edit_parental_consent_path(token: student.consent_token)

    click_button "I agree"

    expect(current_path).to eq(parental_consent_path(student.parental_consent))
    expect(page).to have_css(
      '.parental_consent_electronic_signature .error',
      text: "can't be blank"
    )
  end

  it "handles a valid token, with a valid form" do
    student = FactoryBot.create(:onboarding_student)
    visit edit_parental_consent_path(token: student.reload.consent_token)

    expect(page).to have_content("Consent to participate")
  end

  it "can be filled out on the dashboard" do
    student = FactoryBot.create(:onboarding_student)

    sign_in(student)

    fill_in "Parent or guardian's name", with: "Parent name"
    fill_in "Parent or guardian's email", with: "parent@parent.com"
    click_button "Send the form"

    mail = ActionMailer::Base.deliveries.last
    expect(mail).to be_present, "no parent email sent"
    expect(mail.to).to eq(["parent@parent.com"])
    expect(mail.subject).to include("Your daughter needs permission")
  end

  it "validates parental consent info" do
    student = FactoryBot.create(:onboarding_student)

    sign_in(student)

    fill_in "Parent or guardian's name", with: ""
    fill_in "Parent or guardian's email", with: ""
    click_button "Send the form"

    expect(page).to have_content("can't be blank")
  end
end
