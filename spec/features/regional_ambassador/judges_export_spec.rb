require "rails_helper"

RSpec.describe "/regional_ambassador/judges", type: :request do
  describe "GET judges.json" do
    # Regression for airbrake error
    # Unsupported argument type: Symbol during export
    it "runs export job with grid / params" do
      ra = FactoryBot.create(:ra, :los_angeles, :approved)

      post '/signins', params: {
        account: {
          email: ra.email,
          password: "secret1234",
        },
      }

      FactoryBot.create(:judge, :los_angeles, email: "only-me@me.com")
      FactoryBot.create(:judge, :los_angeles, email: "no_findy-email@judge.com")
      FactoryBot.create(:judge, :chicago, email: "no_findy-region@judge.com")

      url = "/regional_ambassador/judges.json"

      get url, params: {
        filename: "regression",
        judges_grid: {
          name_email: "only-me",
        },
        format: :json,
      }

      csv = File.read("./tmp/regression.csv")
      expect(csv).to include("only-me@me.com")

      expect(csv).not_to include("no_findy-email@judge.com")
      expect(csv).not_to include("no_findy-region@judge.com")
    end
  end
end