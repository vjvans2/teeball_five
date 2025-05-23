require 'rails_helper'

RSpec.describe Assignable do
  let(:assignable_class) { Class.new { include Assignable } }
  let(:assignable_instance) { assignable_class.new }

  def create_fielding_positions
    positions = %w[P C 1B 2B SS 3B _OUT_ OF]
    positions.each do |position|
      rank = case position
      when 'P', '1B' then 1
      when '2B', 'SS', '3B' then 2
      when '_OUT_' then 4
      when 'OF' then 5
      else 3
      end
      create(:fielding_position, name: position, hierarchy_rank: rank)
    end
  end

  before do
    create_fielding_positions
  end

  describe '#initial_assignments' do
    let(:team) { create(:team) }
    let(:number_of_innings) { 4 }
    let(:game) { create(:game, inning_count: number_of_innings) }
    let(:gameday_team) { create(:gameday_team, team: team, game: game) }
    let(:number_of_gameday_players) { 10 }
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
      let!(:innings) { game.innings }
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

  describe '#player_previous_assignments' do
    let(:player) { create(:player) }
    let(:team) { create(:team) }
    let(:number_of_innings) { 4 }
    let(:game) { create(:game, inning_count: number_of_innings) }
    let(:gameday_team) { create(:gameday_team, team: team, game: game) }
    let(:gameday_player) { create(:gameday_player, player: player, gameday_team: gameday_team) }
    let(:innings) { game.innings }

    before do
      innings.each do |inning|
        create(:player_inning, inning: inning, player: player, fielding_position: FieldingPosition.all.sample, game: game)
      end
    end

    it 'returns the previous assignments for the player' do
      result = assignable_instance.player_previous_assignments(gameday_player)

      expect(result).to be_an(Array)
      expect(result.size).to eq(1)
    end
  end
end
