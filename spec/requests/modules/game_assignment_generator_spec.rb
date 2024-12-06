require 'rails_helper'

RSpec.describe GameAssignmentGenerator do
  let(:gag_class) { Class.new { include GameAssignmentGenerator } }
  let(:gag_instance) { gag_class.new }
  let(:team) { create(:team) }
  let(:number_of_innings) { 4 }
  let(:game) { create(:game, inning_count: number_of_innings) }
  let(:gameday_team) { create(:gameday_team, team: team, game: game) }
  let(:players) { create_list(:player, number_of_gameday_players, team: team) }
  let!(:gameday_players) { players.map { |player| create(:gameday_player, player: player, gameday_team: gameday_team) } }
  let(:number_of_gameday_players) { 10 }
  let(:initial_assignments) { [] }

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

  def create_initial_assignments(gameday_team, num_gameday_players, num_innings)
    assignable_class = Class.new { include Assignable }
    assignable_instance = assignable_class.new

    assignable_instance.initial_assignments(gameday_team, num_gameday_players, num_innings)
  end

  before do
    create_fielding_positions
  end

  describe '#assign_position' do
    let(:position) { "LF" }
    let(:inning_index) { 0 }
    let(:override_log) { [] }
    let(:override_counter) { 0 }
    let(:game_assignments) { [ 'LF', nil, nil, nil ] }
    let(:player_assignments) do
      create_initial_assignments(gameday_team, number_of_gameday_players, number_of_innings)
    end
    let(:result) do
      gag_instance.assign_position(
        player_assignments,
        position,
        inning_index,
        override_log,
        override_counter
      )
    end

    context 'when players are available' do
      it 'randomly assigns the position to one of the available players' do
        all_player_ids = player_assignments.map { |pa| pa[:player_id] }

        expect(all_player_ids.include?(result[:selected_player_id])).to eq true
        expect(result[:position]).to eq position
      end
    end

    context 'when no players are available' do
      let(:player_assignments) { [] }
      it 'returns nil' do
        expect(result).to eq nil
      end
    end
  end
end
