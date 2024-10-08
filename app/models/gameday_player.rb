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


  # in a ten person team with an assumed shifting rotation
  # -- positions 1, 2, 3, 4  will leadoff (in order)
  # -- positions 10, 1, 2, 3 will homerun
  # we'll start with just going by leadoff to start

  # the mapping and shuffling maintains the hierarchy and randomizes those in the groups
  def self.shuffle_by_leadoff(gameday_players)
    sorted = gameday_players.sort_by { |gdp| gdp.player[:leadoffs] }
    sorted.group_by { |s| s.player[:leadoffs] }.values.flat_map(&:shuffle)
  end

  # def self.shuffle_by_homerun(gameday_players)
  #   sorted = gameday_players.sort_by { |gdp| gdp.player[:homeruns] }
  #   sorted.group_by { |s| s[:homeruns] }.values.flat_map(&:shuffle)
  # end
end
