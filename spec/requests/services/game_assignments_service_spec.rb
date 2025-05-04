require 'rails_helper'

RSpec.describe GameAssignmentsService, type: :service do
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
    positions = %w[P C 1B 2B SS 3B NILL OF]
    positions.each do |position|
      rank = case position
      when 'P', '1B' then 1
      when '2B', 'SS', '3B' then 2
      when 'NILL' then 4
      when 'OF' then 5
      else 3
      end
      create(:fielding_position, name: position, hierarchy_rank: rank)
    end
  end

  def create_prior_game_assignments
    # each player has 4 player_innings, one for each inning (10x4)
    game.innings.each do |inning|
      gameday_players.each_with_index do |gameday_player, index|
        create(:player_inning,
          batting_order: index + 1,
          player: gameday_player.player,
          inning: inning,
          game: game,
          fielding_position: FieldingPosition.all.sample
        )
      end
    end
  end

  before do
    create_fielding_positions
    create_prior_game_assignments
  end

  describe '#generate_game_assignments' do
    context 'when a gameday_team is provided' do
      it 'generates a games worth of assignments' do
        result = GameAssignmentsService.new(gameday_team).generate_game_assignments
        expect(result).not_to eq nil
        expect(result.size).to eq number_of_gameday_players
      end
    end
  end

  describe '#retrieve_prior_game_assignments' do
    context 'when a previous game_id is provided' do
      it 'retrieves and formats the game data' do
        result = GameAssignmentsService.new(gameday_team).retrieve_prior_game_assignments(game.id)
        result.each do |r|
          expect(r[:player][:name]).not_to eq nil
          expect(r[:player][:jersey_number]).not_to eq nil
          expect(r[:batting_order]).not_to eq nil
          expect(r[:game_assignments].size).to eq number_of_innings
        end
      end
    end
  end
end
