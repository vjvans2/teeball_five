# == Schema Information
#
# Table name: teams
#
#  id               :bigint           not null, primary key
#  city             :string
#  name             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  gameday_teams_id :bigint
#
# Indexes
#
#  index_teams_on_gameday_teams_id  (gameday_teams_id)
#
# Foreign Keys
#
#  fk_rails_...  (gameday_teams_id => gameday_teams.id)
#
class Team < ApplicationRecord
  has_many :players
  has_many :coaches
  has_one :gameday_team

  def full_team_name
    "#{city} #{name}"
  end
end
