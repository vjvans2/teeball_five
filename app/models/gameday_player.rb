class GamedayPlayer < ApplicationRecord
  belongs_to :player
  has_many :player_innings, dependent: :destroy
  belongs_to :gameday_team
end
