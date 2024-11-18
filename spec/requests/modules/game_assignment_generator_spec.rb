require 'rails_helper'

RSpec.describe GameAssignmentGenerator do
  let(:gag_class) { Class.new { include GameAssignmentGenerator } }
  let(:gag_instance) { gag_class.new }

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
  # let(:team) { create(:team) }
  # let(:number_of_innings) { 4 }
  # let(:game) { create(:game, inning_count: number_of_innings) }
  # let(:number_of_players) { 10 }
  # let(:players) { create_list(:player, number_of_players, team: team).sort }
  # let(:player_game_assignments) do
  #   players.map do |player|
  #     {
  #       player_id: player.id,
  #       game_assignments: [ '1B', '2B', 'LF', 'RF' ]
  #     }
  #   end
  # end

  xdescribe '#assign_position' do
    let(:game_assignments) { [ 'LF', nil, nil, nil ] }
    let(:player_assignments) do
      {
        player_id: 1,
        game_assignments: game_assignments
      }
    end
    context 'when the player_game_assignments are only after 1 inning' do
      it 'returns the positions' do
        result = players_available_instance.current_player_game_assignments(player_assignments)
        expect(result[:game_positions]).to eq game_assignments
      end

      it 'returns false for \'full_outfield?\'' do
        result = players_available_instance.current_player_game_assignments(player_assignments)
        expect(result[:full_outfield?]).to eq false
      end

      it 'returns false for \'full_infield?\'' do
        result = players_available_instance.current_player_game_assignments(player_assignments)
        expect(result[:full_infield?]).to eq false
      end
    end

    context 'when the player_game_assignments are after 4 innings' do
      let(:game_assignments) { [ 'LF', 'P', 'RF', 'SS' ] }
      it 'returns the positions' do
        result = players_available_instance.current_player_game_assignments(player_assignments)
        expect(result[:game_positions]).to eq game_assignments
      end

      it 'returns true for \'full_outfield?\'' do
        result = players_available_instance.current_player_game_assignments(player_assignments)
        expect(result[:full_outfield?]).to eq true
      end

      it 'returns true for \'full_infield?\'' do
        result = players_available_instance.current_player_game_assignments(player_assignments)
        expect(result[:full_infield?]).to eq true
      end
    end
  end
end
