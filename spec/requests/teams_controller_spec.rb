require 'rails_helper'

RSpec.describe TeamsController, type: :controller do
  let(:team) { Team.create!(name: 'name', city: 'city') }

  describe '#show' do
    it 'show find a created Team' do
      get :show, params: { id: team.id }

      expect(response).to be_successful
      expect(response).to have_http_status(:ok)
    end
  end
end
