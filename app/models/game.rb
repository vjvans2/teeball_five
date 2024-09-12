# == Schema Information
#
# Table name: games
#
#  id            :bigint           not null, primary key
#  date          :date
#  is_home       :boolean
#  location      :string
#  opponent_name :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  season_id     :bigint
#
# Indexes
#
#  index_games_on_season_id  (season_id)
#
# Foreign Keys
#
#  fk_rails_...  (season_id => seasons.id)
#
class Game < ApplicationRecord
  # has_many :innings, optional: true
  has_many :coaches
  has_many :player_innings, dependent: :destroy
  has_one :gameday_team
  belongs_to :season

  def full_team_name
    "#{city} #{name}"
  end
end
