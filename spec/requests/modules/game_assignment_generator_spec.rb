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

  describe '#generate_player_game_assignments' do
    let(:override_log) { [] }
    let(:override_counter) { 0 }
    let(:player_game_assignments) do
      create_initial_assignments(gameday_team, number_of_gameday_players, number_of_innings)
    end
    let(:result) do
      gag_instance.generate_player_game_assignments(
        player_game_assignments,
        number_of_innings,
        override_log,
        override_counter
      )
    end

    context 'when the team has 10 players' do
      context 'when an empty player_game_assignments is provided' do
        it 'initially has {number_of_innings} nil game_assignments in the array' do
          player_game_assignments.each do |pga|
            expect(pga[:game_assignments].all?(&:nil?)).to eq true
            expect(pga[:game_assignments].size).to eq number_of_innings
          end
        end

        it 'fully populates all player_game_assignments' do
          result.each do |r|
            expect(r[:game_assignments].all?(&:present?)).to eq true
            expect(r[:game_assignments].size).to eq number_of_innings
          end
        end
      end
    end

    context 'when the team has >10 players' do
      let(:number_of_gameday_players) { 13 }
      let(:number_of_innings) { 6 }
      let(:player_game_assignments) do
        create_initial_assignments(gameday_team, number_of_gameday_players, number_of_innings)
      end
      context 'when an empty player_game_assignments is provided' do
        it 'initially has {number_of_innings} nil game_assignments in the array' do
          player_game_assignments.each do |pga|
            expect(pga[:game_assignments].all?(&:nil?)).to eq true
            expect(pga[:game_assignments].size).to eq number_of_innings
          end
        end

        it 'fully populates all player_game_assignments' do
          result.each do |r|
            expect(r[:game_assignments].size).to eq number_of_innings
          end
        end

        it 'has the correct amount of equitable empty spaces in the fielding assignments' do
          the_sum_of_all_nils = result.map { |r| r[:game_assignments] }.flatten.count(nil)
          expect(the_sum_of_all_nils).to eq ((number_of_gameday_players - 10)*4)
        end
      end
    end
  end

  describe '#assign_position' do
    let(:position) { "LF" }
    let(:inning_index) { 0 }
    let(:override_log) { [] }
    let(:override_counter) { 0 }
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
