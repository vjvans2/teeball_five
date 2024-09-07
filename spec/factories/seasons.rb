FactoryBot.define do
  factory :season do
    team { build(:team) }
    # games { build(:game) } Is this a typo? Should each game belong to a season? Or can a game be a part of different seasons?
  end
end
