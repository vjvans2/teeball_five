require 'rails_helper'

RSpec.describe Coach, type: :model do
  describe 'validations' do
    let(:coach) { build(:coach) }

    it "has a working factory" do
      expect(coach).to be_valid
    end
  end

  describe "#full_name" do
    subject { coach.full_name }

    let(:coach) { build(:coach, first_name: first_name, last_name: last_name) }
    let(:first_name) { "Nicholas" }
    let(:last_name) { "Turon" }

    it { is_expected.to eq("Nicholas Turon") }
  end
end
