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
    describe '#choose_and_remove' do
      context 'when params are valid' do
        it 'grabs a random position' do
          random = GetRandomPosition.new.choose_and_remove
          expect(positions.include?(random)).to be_truthy
        end
      end

      context 'when available_positions.empty? == true' do
        it 'returns nil' do
          picked = FieldingPosition.all.map(&:name)
          random = GetRandomPosition.new(picked).choose_and_remove
          expect(random).to eq nil
        end
      end
    end
  end
end
