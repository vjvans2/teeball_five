require 'rails_helper'

RSpec.describe GameAssignmentsService, type: :service do
  describe '#generate_game_assignments' do
    let(:team) { create(:team) }
    let(:number_of_innings) { 4 }
    let(:override_log) { [] }
    let(:override_counter) { 0 }
    let(:game) { create(:game, inning_count: number_of_innings) }
    let(:gameday_team) { create(:gameday_team, team: team, game: game) }
    let(:number_of_gameday_players) { 10 }
    let!(:players) { create_list(:player, number_of_gameday_players, team: team) }
    let!(:gameday_players) { players.map { |player| create(:gameday_player, player: player, gameday_team: gameday_team) } }

    def create_fielding_positions
      positions = %w[LF LC RC RF P C 1B 2B SS 3B]
      positions.each do |position|
        rank = case position
        when 'P', '1B' then 1
        when '2B', 'SS', '3B' then 2
        else 3
        end
        create(:fielding_position, name: position, hierarchy_rank: rank)
      end
    end

    before do
      create_fielding_positions
    end

    context 'when params are valid' do
      it 'creates player_innings correctly' do
        result = GameAssignmentsService.new(gameday_team).generate_game_assignments

        expect(result).not_to eq nil
      end
    end
  end
end
