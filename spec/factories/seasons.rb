FactoryBot.define do
  factory :season do
    team { build(:team) }
  end
end
