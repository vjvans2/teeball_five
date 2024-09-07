require 'rails_helper'

RSpec.describe Player, type: :model do
  describe 'validations' do
    let(:player) { build(:player) }

    it "has a working factory" do
      expect(player).to be_valid
    end
  end

  describe "#full_name" do
    subject { player.full_name }

    let(:player) { build(:player, :first_name => first_name, :last_name => last_name) }
    let(:first_name) { "Someone" }
    let(:last_name) { "Else" }

    it { is_expected.to eq("Someone Else") }
  end
end
