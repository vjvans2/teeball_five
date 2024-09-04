require 'rails_helper'

RSpec.describe GetRandomPosition, type: :service do
  describe '#GetRandomPosition' do
    let(:high_tier_positions) { %w[P 1B] }
    let(:mid_tier_positions) { %w[C 2B SS 3B] }
    let(:positions) { %w[LF LC RC RF P C 1B 2B SS 3B] }
    let!(:create_positions) do
      positions.each do |position|
        case position
        when *high_tier_positions
          create(:fielding_position, :high_tier, name: position)
        when *mid_tier_positions
          create(:fielding_position, :mid_tier, name: position)
        else
          create(:fielding_position, name: position)
        end
      end
    end
    let(:number_of_innings) { 4 }
    let(:number_of_gameday_players) { 11 }
    let(:assignments) { Array.new(number_of_innings) { Array.new(number_of_gameday_players) } }

    describe '#choose_and_remove' do
      context 'when params are valid' do
        it 'grabs a random position' do
          player_index = 0
          klass = GetRandomPosition.new(assignments, 0)

          random = klass.choose_and_remove(player_index)
          expect(positions.include?(random)).to be_truthy
        end
      end

      context 'when available_positions are empty' do
        it 'returns nil' do
          player_index = 0
          picked = FieldingPosition.all.map(&:name)
          klass = GetRandomPosition.new(assignments, 0, picked)
          random = klass.choose_and_remove(player_index)
          expect(random).to eq nil
        end
      end
    end

    describe '#is_valid_inning?' do
      context 'when the inning is full with all positions' do
        it 'returns true' do
          assignments[0] = positions
          klass = GetRandomPosition.new(assignments, 0)
          expect(klass.is_valid_inning?).to eq true
        end
      end

      context 'when the inning does not include all positions' do
        it 'returns false' do
          assignments[0] = [ 'hi mom', 'hi dad' ]
          klass = GetRandomPosition.new(assignments, 0)
          expect(klass.is_valid_inning?).to eq false
        end
      end
    end
  end
end
