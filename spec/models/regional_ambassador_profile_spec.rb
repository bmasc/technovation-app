require "rails_helper"

RSpec.describe RegionalAmbassadorProfile do
  it "emails on decline" do
    ambassador = FactoryGirl.create(:regional_ambassador)
    ambassador.declined!
    expect(ActionMailer::Base.deliveries.last.subject).to eq("Your Regional Ambassador application has been declined.")
  end
end
