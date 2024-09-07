# == Schema Information
#
# Table name: gameday_teams
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :bigint           not null
#  team_id    :bigint           not null
#
# Indexes
#
#  index_gameday_teams_on_game_id  (game_id)
#  index_gameday_teams_on_team_id  (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#  fk_rails_...  (team_id => teams.id)
#
class GamedayTeam < ApplicationRecord
  has_one :game
  has_many :gameday_players
  belongs_to :team
end
