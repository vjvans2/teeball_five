class Player < ApplicationRecord
  belongs_to :player_inning
  belongs_to :gameday_player
  belongs_to :team

  def full_name
    "#{first_name} #{last_name}"
  end
end
