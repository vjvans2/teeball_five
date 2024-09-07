# == Schema Information
#
# Table name: player_innings
#
#  id                   :bigint           not null, primary key
#  batting_order        :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  fielding_position_id :bigint
#  game_id              :bigint           not null
#  inning_id            :bigint           not null
#  player_id            :bigint           not null
#
# Indexes
#
#  index_player_innings_on_fielding_position_id  (fielding_position_id)
#  index_player_innings_on_game_id               (game_id)
#  index_player_innings_on_inning_id             (inning_id)
#  index_player_innings_on_player_id             (player_id)
#
# Foreign Keys
#
#  fk_rails_...  (fielding_position_id => fielding_positions.id)
#  fk_rails_...  (game_id => games.id)
#  fk_rails_...  (inning_id => innings.id)
#  fk_rails_...  (player_id => players.id)
#
class PlayerInning < ApplicationRecord
  belongs_to :player
  belongs_to :inning
  belongs_to :game
  belongs_to :gameday_player
end
