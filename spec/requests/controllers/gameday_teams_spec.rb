require 'rails_helper'

RSpec.describe "GamedayTeams", type: :request do
  xdescribe "GET /show" do
    it "returns http success" do
      get "/gameday_teams/show"
      expect(response).to have_http_status(:success)
    end
  end

  xdescribe "GET /post" do
    it "returns http success" do
      get "/gameday_teams/post"
      expect(response).to have_http_status(:success)
    end
  end
end
