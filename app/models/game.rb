class Game < ApplicationRecord
  # has_many :innings, optional: true
  has_many :coaches
  has_one :gameday_team

  def full_team_name
    "#{city} #{name}"
  end
end
