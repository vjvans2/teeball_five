FactoryBot.define do
  factory :coach do
    first_name { "Jimbob" }
    last_name  { "Muscles" }
    is_head_coach { false }
    association :team
    association :associated_player, factory: :player
  end
end
