require "rails_helper"

RSpec.describe Account do
  subject(:account) { FactoryGirl.create(:account) }

  it "sets an auth token" do
    expect(account.auth_token).not_to be_blank
  end

  it "requires a secure password when invited" do
    FactoryGirl.create(:team_member_invite, invitee_email: "test@account.com")
    account = FactoryGirl.build(:account, email: "test@account.com", password: "short")
    expect(account).not_to be_valid
    expect(account.errors[:password]).to eq(["is too short (minimum is 8 characters)"])
  end

  it "re-subscribes new email addresses" do
    account = FactoryGirl.create(:account)

    expect(UpdateEmailListJob).to receive(:perform_later)
      .with(account.email, "new@email.com", account.full_name, "APPLICATION_LIST_ID", [])

    account.update_attributes(email: "new@email.com")
  end

  it "doesn't need a BG check outside of the US" do
    account = FactoryGirl.create(%i{mentor regional_ambassador}.sample, country: "BR")
    expect(account).to be_background_check_complete
  end

  it "calculates age" do
    account.date_of_birth = 15.years.ago + 1.day
    expect(account.age).to eq(14)

    account.date_of_birth = 15.years.ago
    expect(account.age).to eq(15)
  end

  it "calculates age compared to a particular date" do
    account.date_of_birth = 15.years.ago + 3.months
    expect(account.age(3.months.from_now)).to eq(15)
  end
end
