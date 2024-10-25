require 'rails_helper'

RSpec.describe "GamedayPlayers", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/gameday_players/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /post" do
    it "returns http success" do
      get "/gameday_players/post"
      expect(response).to have_http_status(:success)
    end
  end
end
