FactoryBot.define do
  factory :inning do
    inning_number { 1 }
    game { build(:game) }
  end
end
