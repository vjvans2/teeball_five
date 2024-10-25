require 'rails_helper'

RSpec.describe Player, type: :model do
  describe 'validations' do
    let(:team) { create(:team) }
    let(:player) { create(:player, team: team) }

    it "has a working factory" do
      expect(player).to be_valid
    end

    context "without a first name" do
      let(:team) { create(:team) }
      let(:player) { create(:player, team: team, first_name: nil) }

      it 'throws an error' do
        expect { player }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "without a team" do
      let(:team) { create(:team) }
      let(:player) { create(:player, team: nil) }

      it 'throws an error' do
        expect { player }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe "#full_name" do
    subject { player.full_name }

    let(:team) { create(:team) }
    let(:player) { create(:player, team: team, first_name: first_name, last_name: last_name) }
    let(:first_name) { "Someone" }
    let(:last_name) { "Else" }

    it { is_expected.to eq("Someone Else") }
  end
end
