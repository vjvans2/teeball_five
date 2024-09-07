# == Schema Information
#
# Table name: players
#
#  id            :bigint           not null, primary key
#  first_name    :string
#  jersey_number :integer
#  last_name     :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  team_id       :bigint           not null
#
# Indexes
#
#  index_players_on_team_id  (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (team_id => teams.id)
#
class Player < ApplicationRecord
  # belongs_to :player_inning
  # belongs_to :gameday_player
  belongs_to :team

  def full_name
    "#{first_name} #{last_name}"
  end
end
