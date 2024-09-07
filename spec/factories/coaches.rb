FactoryBot.define do
  factory :coach do
    first_name { "Jimbob" }
    last_name  { "Muscles" }
    is_head_coach { false } # but he wishes he was
    associated_player_id { nil }
    team { build(:team) }
  end
end
