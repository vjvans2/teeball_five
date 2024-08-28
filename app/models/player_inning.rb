class PlayerInning < ApplicationRecord
  belongs_to :player
  belongs_to :inning
  belongs_to :game
  belongs_to :gameday_player
end
