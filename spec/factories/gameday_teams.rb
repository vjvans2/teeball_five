FactoryBot.define do
  factory :gameday_team do
    game { build(:game) }
    team { build(:team) }
  end
end
