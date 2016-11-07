require "rails_helper"

RSpec.describe Mentor::SignupsController do
  describe "POST #create" do
    it "saves the bio" do
      controller.set_cookie(:signup_token, SignupAttempt.create!(email: "joe@example.com", password: "secret1234", status: SignupAttempt.statuses[:active]).signup_token)

      post :create, mentor_profile: FactoryGirl.attributes_for(
        :mentor,
        bio: "Hello, bio"
      ).merge(account_attributes: FactoryGirl.attributes_for(:account))

      expect(MentorProfile.last.bio).to eq("Hello, bio")
    end
  end
end
