require 'rails_helper'

RSpec.describe PlayersAvailable do
  let(:players_available_class) { Class.new { include PlayersAvailable } }
  let(:players_available_instance) { players_available_class.new }

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

  describe '#current_player_game_assignments' do
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

  describe '#is_valid_choice?' do
    let(:game_assignments) { [ nil, nil, nil, nil ] }
    let(:player_game_assignments) do
      {
        player_id: 1,
        game_assignments: game_assignments,
        previous_assignments: []
      }
    end
    let(:selected_position) { 'P' }
    let(:inning_index) { 0 }
    let(:result) do
      players_available_instance.is_valid_choice?(
        player_game_assignments,
        selected_position,
        inning_index
      )
    end

    context 'when in the first inning of the first game of the season' do
      it 'will always be valid' do
        expect(result[:valid]).to be true
      end
    end

    context 'when a player has already been assigned that position during a game' do
      let(:game_assignments) { [ 'P', nil, nil, nil ] }
      let(:inning_index) { 1 }
      it 'will not be valid' do
        expect(result[:valid]).to be false
      end
      it 'will cite reason as \'repeat position\'' do
        expect(result[:reason]).to eq 'repeat position'
      end
    end

    context 'when a player has already been assigned two outfield positions during a game' do
      let(:game_assignments) { [ 'LF', 'RF', nil, nil ] }
      let(:inning_index) { 2 }
      let(:selected_position) { "RC" }
      it 'will not be valid' do
        expect(result[:valid]).to be false
      end
      it 'will cite reason as \'full_outfield\'' do
        expect(result[:reason]).to eq 'full_outfield'
      end
    end

    context 'when a player has already been assigned two infield positions during a game' do
      let(:game_assignments) { [ '1B', '3B', nil, nil ] }
      let(:inning_index) { 2 }
      it 'will not be valid' do
        expect(result[:valid]).to be false
      end
      it 'will cite reason as \'full_infield\'' do
        expect(result[:reason]).to eq 'full_infield'
      end
    end

    context 'when a player doesn\'t trigger one of the false conditions' do
      let(:game_assignments) { [ '1B', 'LF', nil, nil ] }
      let(:inning_index) { 2 }
      it 'will not be valid' do
        expect(result[:valid]).to be true
      end
    end
  end

  describe '#players_with_a_position_this_inning' do
    let(:team) { create(:team) }
    let(:number_of_innings) { 4 }
    let(:game) { create(:game, inning_count: number_of_innings) }
    let(:number_of_players) { 10 }
    let(:players) { create_list(:player, number_of_players, team: team).sort }
    let(:player_game_assignments) do
      players.map do |player|
        {
          player_id: player.id,
          game_assignments: [ '1B', '2B', 'LF', 'RF' ]
        }
      end
    end
    let(:inning_index) { 0 }
    let(:result) do
      players_available_instance.players_with_a_position_this_inning(
        player_game_assignments,
        inning_index
      )
    end

    context 'when provided an inning_index when all players have been assigned' do
      it 'returns a list of player_ids who already have been assigned that inning' do
        expect(result.size).to eq number_of_players
      end
    end

    context 'when provided an inning_index when not all players have been assigned' do
      let(:player_game_assignments) do
        odd_players = []
        players.each_with_index do |player, index|
          if index.odd?
            odd_players << {
              player_id: player.id,
              game_assignments: [ 'P', 'LF', 'RF', '2B' ]
            }
          end
        end
        odd_players
      end
      it 'returns a list of player_ids who already have been assigned that innning' do
        expect(result.size).to eq 5
      end
    end
  end

  describe '#players_ids_in_line_to_play_position' do
    context 'when given a position' do
      it 'gives an ordered list of player_ids whose \'turn\' it is to be {position}' do
      end
    end
  end

  describe '#filter_valid_players' do
    context 'when there are valid_players' do
      it 'provides a list of player_ids that are valid for the given position' do
      end
    end
    context 'when there are no valid_players' do
      it 'logs the invalid_players\' messages' do
      end
      it 'returns a list of the invalid player_ids' do
      end
    end
  end

  describe '#available_players' do
    context 'when a position, inning, and player_game_assignments are provided' do
      it 'returns a list of valid_players that could play that position in that inning' do
      end
    end
  end
end
