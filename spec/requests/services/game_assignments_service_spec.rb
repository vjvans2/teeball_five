require 'rails_helper'

RSpec.describe GameAssignmentsService, type: :service do
  xdescribe '#generate_game_assignments' do
    let(:team) { create(:team) }
    let(:game) { create(:game) }
    let(:gameday_team) { create(:gameday_team, team: team, game: game) }
    let(:number_of_gameday_players) { 10 }
    let(:number_of_innings) { 4 }
    !let(:players) { create_list(:player, number_of_gameday_players, team: team) }
    !let(:gameday_players) { players.map { |player| create(:gameday_player, player: player, gameday_team: gameday_team) } }

    context 'when params are valid' do
      it 'creates player_innings correctly' do
        result = GameAssignmentsService.new(gameday_team).generate_game_assignments

        expect(result).not_to eq nil
      end
    end
  end
end
