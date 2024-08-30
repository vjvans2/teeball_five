class Game < ApplicationRecord
  # has_many :innings, optional: true
  has_many :coaches
  has_one :gameday_team
  has_many :player_innings, dependent: :destroy

  def full_team_name
    "#{city} #{name}"
  end
end
