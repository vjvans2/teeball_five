FactoryBot.define do
  factory :inning do
    inning_number { |n| n }
    association :game
  end
end
