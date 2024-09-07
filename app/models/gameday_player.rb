# == Schema Information
#
# Table name: gameday_players
#
#  id                :bigint           not null, primary key
#  is_present        :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  gameday_team_id   :bigint           not null
#  player_id         :bigint           not null
#  player_innings_id :bigint
#
# Indexes
#
#  index_gameday_players_on_gameday_team_id    (gameday_team_id)
#  index_gameday_players_on_player_id          (player_id)
#  index_gameday_players_on_player_innings_id  (player_innings_id)
#
# Foreign Keys
#
#  fk_rails_...  (gameday_team_id => gameday_teams.id)
#  fk_rails_...  (player_id => players.id)
#  fk_rails_...  (player_innings_id => player_innings.id)
#
class GamedayPlayer < ApplicationRecord
  belongs_to :player
  has_many :player_innings, dependent: :destroy
  belongs_to :gameday_team
end
