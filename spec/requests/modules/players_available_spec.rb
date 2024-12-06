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

  describe '#player_ids_in_line_to_play_position' do
    let(:selected_position) { 'LF' }
    let(:player_game_assignments) do
      [
        { player_id: 1, previous_assignments: [ { game_assignments: [ { position: 'LF' } ] } ], game_assignments: [] },
        { player_id: 2, previous_assignments: [], game_assignments: [] },
        { player_id: 3, previous_assignments: [ { game_assignments: [ { position: 'RF' } ] } ], game_assignments: [ 'LF' ] }
      ]
    end
    let(:already_placed) { [ 3 ] }
    let(:result) do
      players_available_instance.player_ids_in_line_to_play_position(
        selected_position,
        player_game_assignments,
        already_placed
      )
    end
    context 'when previous_assignments and already_placed add limits' do
      it 'returns player 2 as only eligible player for the position' do
        expect(result).to eq([ 2 ]) # Player 2 has never played LF, Player 1 has once.  Player 3 is already placed.
      end
    end

    context 'when previous_assignments present only' do
      let(:player_game_assignments) do
        [
          { player_id: 1, previous_assignments: [ { game_assignments: [ { position: 'LF' } ] } ], game_assignments: [] },
          { player_id: 2, previous_assignments: [], game_assignments: [] },
          { player_id: 3, previous_assignments: [ { game_assignments: [ { position: 'RF' } ] } ], game_assignments: [] }
        ]
      end
      let(:already_placed) { [] }
      let(:result) do
        players_available_instance.player_ids_in_line_to_play_position(
          selected_position,
          player_game_assignments,
          already_placed
        )
      end
      it 'returns players 2 and 3 as eligible' do
        expect(result).to eq([ 2, 3 ])
      end
    end
  end

  describe '#filter_valid_players' do
    let(:player_game_assignments) do
      [
        { player_id: 1, previous_assignments: [], game_assignments: [] },
        { player_id: 2, previous_assignments: [], game_assignments: [ 'LF' ] }
      ]
    end
    let(:player_ids) { [ 1, 2 ] }
    let(:position) { 'LF' }
    let(:inning_index) { 0 }
    let(:override_log) { [] }
    let(:override_counter) { 0 }
    let(:result) do
      players_available_instance.filter_valid_players(
        player_game_assignments,
        player_ids,
        position,
        inning_index,
        override_log,
        override_counter
      )
    end

    context 'when there are valid players' do
      it 'returns a list of valid player_ids' do
        expect(result).to include(1) # Player 1 has no previous assignments and is valid.
      end
    end

    context 'when there are no valid players' do
      let(:player_ids) { [ 2 ] } # Only player 2, who has already played LF, is considered.
      it 'returns a list of invalid player_ids' do
        expect(result).to eq([ 2 ])
      end
    end
  end

  describe '#available_players' do
    let(:player_game_assignments) do
      [
        { player_id: 1, previous_assignments: [], game_assignments: [] },
        { player_id: 2, previous_assignments: [], game_assignments: [ 'LF' ] }
      ]
    end
    let(:selected_position) { 'LF' }
    let(:inning_index) { 0 }
    let(:override_log) { [] }
    let(:override_counter) { 0 }
    let(:result) do
      players_available_instance.available_players(
        player_game_assignments,
        selected_position,
        inning_index,
        override_log,
        override_counter
      )
    end

    context 'when not all players are already placed' do
      it 'returns a list of valid players for the position' do
        expect(result).to eq([ 1 ]) # Player 1 is valid for LF.
      end
    end

    context 'when all players are already placed' do
      let(:player_game_assignments) do
        [
          { player_id: 1, previous_assignments: [], game_assignments: [ 'LF' ] },
          { player_id: 2, previous_assignments: [], game_assignments: [ 'LF' ] }
        ]
      end
      it 'returns an empty list' do
        expect(result).to be_empty
      end
    end
  end
end
