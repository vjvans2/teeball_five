class Team < ApplicationRecord
  has_many :players
  has_many :coaches
  has_one :gameday_team

  def full_team_name
    "#{city} #{name}"
  end
end
