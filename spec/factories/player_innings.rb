FactoryBot.define do
  factory :player_inning do
    batting_order { 1 }
    association :player
    association :inning
    association :fielding_position
    association :game
  end
end
