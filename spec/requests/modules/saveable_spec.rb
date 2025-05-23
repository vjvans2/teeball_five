require 'rails_helper'

RSpec.describe Saveable do
  let(:saveable_class) { Class.new { include Saveable } }
  let(:saveable_instance) { saveable_class.new }

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

  describe '#save_player_inning_assignments' do
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
    let(:product) { number_of_innings * number_of_players }
    context 'when the player_game_assignments are completed and are valid' do
      it 'creates \'player_innings\' for every player in each inning' do
        expect(PlayerInning.all.count).to eq 0

        saveable_instance.save_player_inning_assignments(player_game_assignments, game.id, 4)

        expect(PlayerInning.all.count).to eq product
      end
    end
  end

  describe '#save_player_counters' do
    let(:team) { create(:team) }
    let(:number_of_innings) { 4 }
    let(:game) { create(:game, inning_count: number_of_innings) }
    let(:number_of_players) { 10 }
    let(:players) { create_list(:player, number_of_players, team: team).sort }
    let(:player_game_assignments) do
      players.map do |player|
        { player_id: player.id }
      end
    end

    context "when the game is over" do
      it 'increments the leadoffs of the first four players in the batting order' do
        initial_leadoff_values = Player.find(players.first(4).map(&:id)).map(&:leadoffs)

        saveable_instance.save_player_counters(player_game_assignments)

        expected_final_leadoff_values = initial_leadoff_values.map(&:next)
        incremented = Player.find(players.first(4).map(&:id)).map(&:leadoffs)

        expect(incremented).to eq expected_final_leadoff_values
      end

      it 'increments the homeruns of the first three and last player in the batting order' do
        homerun_player_ids = players.first(3).map(&:id) + [ players.last.id ]
        initial_homerun_values = Player.find(homerun_player_ids).map(&:homeruns)

        saveable_instance.save_player_counters(player_game_assignments)

        expected_final_homerun_values = initial_homerun_values.map(&:next)
        incremented = Player.find(homerun_player_ids).map(&:homeruns)

        expect(incremented).to eq expected_final_homerun_values
      end
    end
  end
end
