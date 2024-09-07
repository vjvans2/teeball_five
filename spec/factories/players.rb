FactoryBot.define do
  factory :player do
    first_name { "Cara" }
    last_name  { "Clueless" }
    jersey_number { 69420 }
    team { build(:team) }
  end
end
