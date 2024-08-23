class PlayerInning < ApplicationRecord
  has_one :player
  has_one :inning
  has_one :fielding_position
end
