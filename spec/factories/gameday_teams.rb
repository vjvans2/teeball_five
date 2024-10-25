FactoryBot.define do
  factory :gameday_team do
    association :game
    association :team
  end
end
