# == Schema Information
#
# Table name: seasons
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  games_id   :bigint           not null
#  team_id    :bigint           not null
#
# Indexes
#
#  index_seasons_on_games_id  (games_id)
#  index_seasons_on_team_id   (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (games_id => games.id)
#  fk_rails_...  (team_id => teams.id)
#
class Season < ApplicationRecord
  has_many :games
  has_one :team
end
