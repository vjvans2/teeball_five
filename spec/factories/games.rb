FactoryBot.define do
  factory :game do
    date { Date.today }
    is_home { true }
    location { "Over the Rainbow" }
    opponent_name { "Base Invaders" }
    association :season
  end
end
