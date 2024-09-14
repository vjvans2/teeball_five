# == Schema Information
#
# Table name: gameday_players
#
#  id              :bigint           not null, primary key
#  is_present      :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  gameday_team_id :bigint           not null
#  player_id       :bigint           not null
#
# Indexes
#
#  index_gameday_players_on_gameday_team_id  (gameday_team_id)
#  index_gameday_players_on_player_id        (player_id)
#
# Foreign Keys
#
#  fk_rails_...  (gameday_team_id => gameday_teams.id)
#  fk_rails_...  (player_id => players.id)
#
class GamedayPlayer < ApplicationRecord
  belongs_to :gameday_team
  belongs_to :player

  # TODO -- this will need to be restricted by game/season
  has_many :player_innings, through: :player
end
