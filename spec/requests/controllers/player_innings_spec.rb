require 'rails_helper'

RSpec.describe "PlayerInnings", type: :request do
  xdescribe "GET /post" do
    it "returns http success" do
      get "/player_innings/post"
      expect(response).to have_http_status(:success)
    end
  end
end
