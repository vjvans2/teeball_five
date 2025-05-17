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
  has_many :coaches
  has_many :innings
  has_one :gameday_team
  belongs_to :season

  def pretty_date
    date.strftime("%B %d, %Y")
  end

  def name
    "#{pretty_date} --- #{season.team.full_team_name}"
  end

  def full_legal_game_name
    "#{name} vs. #{opponent_name} (#{is_home ? 'HOME' : 'AWAY'})"
  end

  def game_assignments
    GameAssignmentsService.new(gameday_team).retrieve_prior_game_assignments
  end

  def current_game_inning_ids
    GameAssignmentsService.new(gameday_team).current_game_inning_ids
  end
end
