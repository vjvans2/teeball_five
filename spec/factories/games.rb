FactoryBot.define do
  factory :game do
    date { Date.new(2024, 3, 31) }
    is_home { false }
    location { "Over the Rainbow" }
    opponent_name { "Base Invators" }
    season { build(:season) }
  end
end
