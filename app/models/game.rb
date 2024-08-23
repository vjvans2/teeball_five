class Game < ApplicationRecord
  has_many :innings
  has_many :coaches
  has_one :gameday_team

  def full_team_name
    "#{city} #{name}"
  end
end

class Inning < ApplicationRecord
  has_one :game
end

class PlayerInning < ApplicationRecord
  has_one :player
  has_one :inning
  has_one :fielding_position
end

class GamedayPlayer < ApplicationRecord
  has_one :game
  has_one :player
  has_many :player_innings
end

class GamedayTeam < ApplicationRecord
  has_one :game
  has_many :gameday_players
end

class Season < ApplicationRecord
  has_many :games
  has_one :team
end