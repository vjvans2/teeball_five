FactoryBot.define do
  factory :fielding_position do
    hierarchy_rank { 3 }
    name { "LF" }

    trait :high_tier do
      hierarchy_rank { 1 }
    end

    trait :mid_tier do
      hierarchy_rank { 2 }
    end
  end
end
