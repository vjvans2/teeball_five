FactoryBot.define do
  factory :season do
    name { "Summer 2024" }
    association :team
  end
end
