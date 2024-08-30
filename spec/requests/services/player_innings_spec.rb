require 'rails_helper'

RSpec.describe GenerateGameAssignmentsService, type: :service do
  xdescribe '#generate_game_assignments' do
    context 'when params are valid' do
      let(:valid_params) { { name: 'Test User', email: 'test@example.com', password: 'password', password_confirmation: 'password' } }

      it 'creates player_innings correctly' do
        result = GenerateGameAssignmentsService.new(valid_params).generate_game_assignments

        expect(result[:success]).to be_truthy
        expect(result[:user]).to be_persisted
      end
    end
  end
end
