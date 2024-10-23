FactoryBot.define do
  factory :player do
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    jersey_number { rand(1..99) }
    leadoffs { rand(1..9) }
    homeruns { rand(1..9) }
    postgame_cheer { rand(1..9) }
    direct_out { rand(1..9) }
    assist_out { rand(1..9) }
    sat_out { rand(1..9) }
    association :team
  end
end
