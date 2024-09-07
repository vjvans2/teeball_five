FactoryBot.define do
  factory :player_inning do
    batting_order { 1 }
    fielding_position { build(:fielding_position) }
    game { build(:game) }
    inning { build(:inning) }
    player { build(:player) }
  end
end
