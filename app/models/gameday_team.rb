class GamedayTeam < ApplicationRecord
  has_one :game
  has_many :gameday_players
  belongs_to :team
end
