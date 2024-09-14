require 'rails_helper'

RSpec.describe Team, type: :model do
  describe 'validations' do
    let(:team) { build(:team) }

    it "has a working factory" do
      expect(team).to be_valid
    end

    context "without a name" do
      let(:team) { build(:team, name: nil) }

      it { expect(team).not_to be_valid }
    end

    context "without a city" do
      let(:team) { build(:team, city: nil) }

      it { expect(team).not_to be_valid }
    end
  end

  describe "#full_team_name" do
    subject { team.full_team_name }

    let(:team) { build(:team, city: city, name: name) }
    let(:city) { "Chillicothe" }
    let(:name) { "Swingers" }

    it { is_expected.to eq("Chillicothe Swingers") }
  end
end
