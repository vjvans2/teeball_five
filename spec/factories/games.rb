FactoryBot.define do
  factory :game do
    date { Date.today }
    is_home { true }
    location { "Over the Rainbow" }
    opponent_name { "Base Invaders" }
    association :season

    transient do
      inning_count { 4 }
    end

    after(:create) do |game, evaluator|
      (1..evaluator.inning_count).each do |num|
        create(:inning, inning_number: num, game: game)
      end
    end
  end
end
