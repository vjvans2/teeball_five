FactoryBot.define do
  factory :gameday_player do
    is_present { true }
    player { build(:player) }
    gameday_team  { build(:gameday_team) }
  end
end
