require 'rails_helper'
require 'date'

RSpec.describe GamesController, type: :controller do
  describe "GET /show" do
    let(:game) { Game.create!(location: 'location', is_home: true, opponent_name: 'opponent', date: Date.today) }

    it "returns http success" do
      get :show, params: { id: game.id }
      expect(response).to have_http_status(:success)
    end
  end

  # describe "GET /post" do
  #   it "returns http success" do
  #     get "/games/post"
  #     expect(response).to have_http_status(:success)
  #   end
  # end
end
