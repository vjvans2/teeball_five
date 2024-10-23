require 'rails_helper'

RSpec.describe Assignable do
  let(:assignable_class) { Class.new { include Assignable } }
  let(:assignable_instance) { assignable_class.new }

  describe '#initial_assignments' do
    let!(:fielding_positions) do
      high_tier_positions = %w[P 1B]
      mid_tier_positions = %w[2B SS 3B]
      positions = %w[LF LC RC RF P C 1B 2B SS 3B]

      positions.each do |position|
        rank = case position
        when *high_tier_positions
            1
        when *mid_tier_positions
            2
        else
            3
        end
        create(:fielding_position, name: position, hierarchy_rank: rank)
      end
    end
    let(:team) { create(:team) }
    let(:game) { create(:game) }
    let(:gameday_team) { create(:gameday_team, team: team, game: game) }
    let(:number_of_gameday_players) { 10 }
    let(:number_of_innings) { 4 }
    let(:players) { create_list(:player, number_of_gameday_players, team: team) }
    let(:gameday_players) { players.map { |player| create(:gameday_player, player: player, gameday_team: gameday_team) } }

    before do
      allow(GamedayPlayer).to receive(:shuffle_by_leadoff).with(gameday_team.gameday_players).and_return(gameday_players)
    end

    context "when this is the first game of the season" do
      it 'creates an assignment list with empty previous assignments' do
        result = assignable_instance.initial_assignments(gameday_team, number_of_gameday_players, number_of_innings)

        expect(result.size).to eq(number_of_gameday_players)
        result.each_with_index do |assignment, index|
          expect(assignment[:player_id]).to eq(gameday_players[index].player_id)
          expect(assignment[:leadoffs]).to eq(gameday_players[index].player.leadoffs)
          expect(assignment[:homeruns]).to eq(gameday_players[index].player.homeruns)
          expect(assignment[:game_assignments]).to eq(Array.new(number_of_innings) { nil })
          expect(assignment[:previous_assignments]).to eq([])
        end
      end
    end

    context "when this is not the first game of the season" do
      let(:innings) { create_list(:inning, number_of_innings, game: game) }
      before do
        players.each do |player|
          innings.each do |inning|
            create(:player_inning, inning: inning, player: player, fielding_position: FieldingPosition.all.sample, game: game)
          end
        end
      end

      it 'creates an assignment list with previous assignments with data' do
        result = assignable_instance.initial_assignments(gameday_team, number_of_gameday_players, number_of_innings)

        expect(result.size).to eq(number_of_gameday_players)
        result.each_with_index do |assignment, index|
          expect(assignment[:player_id]).to eq(gameday_players[index].player_id)
          expect(assignment[:leadoffs]).to eq(gameday_players[index].player.leadoffs)
          expect(assignment[:homeruns]).to eq(gameday_players[index].player.homeruns)
          expect(assignment[:game_assignments]).to eq(Array.new(number_of_innings) { nil })
          previous_game = assignment[:previous_assignments].first[:game_assignments].size
          expect(previous_game).to eq(4)
        end
      end
    end
  end

  xdescribe '#player_previous_assignments' do
    let(:player) { create(:player) }
    let(:game) { create(:game) }
    let(:inning1) { create(:inning, game: game, inning_number: 1) }
    let(:inning2) { create(:inning, game: game, inning_number: 2) }
    let(:fielding_position) { create(:fielding_position, name: 'Pitcher') }
    let(:player_inning1) { create(:player_inning, player: player, inning: inning1, fielding_position: fielding_position, batting_order: 1, game: game) }
    let(:player_inning2) { create(:player_inning, player: player, inning: inning2, fielding_position: fielding_position, batting_order: 1, game: game) }

    before do
      player_inning1
      player_inning2
    end

    it 'returns the previous assignments for the player' do
      result = assignable_instance.player_previous_assignments(player.gameday_players.first)

      expect(result).to be_an(Array)
      expect(result.size).to eq(1)
      expect(result.first[:game_id]).to eq(game.id)
      expect(result.first[:batting_order]).to eq(player_inning1.batting_order)
      expect(result.first[:game_assignments]).to contain_exactly(
        { inning_number: 1, position: 'Pitcher' },
        { inning_number: 2, position: 'Pitcher' }
      )
    end
  end
end
