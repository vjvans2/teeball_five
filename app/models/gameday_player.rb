class GamedayPlayer < ApplicationRecord
  has_one :game
  has_one :player
  has_many :player_innings
end
