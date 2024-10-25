FactoryBot.define do
  factory :gameday_player do
    is_present { true }
    association :player
    association :gameday_team
  end
end
