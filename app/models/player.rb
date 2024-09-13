# == Schema Information
#
# Table name: players
#
#  id             :bigint           not null, primary key
#  assist_out     :bigint
#  direct_out     :bigint
#  first_name     :string
#  homeruns       :bigint
#  jersey_number  :integer
#  last_name      :string
#  leadoffs       :bigint
#  postgame_cheer :bigint
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  team_id        :bigint           not null
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
  belongs_to :team
  has_many :player_innings

  def full_name
    "#{first_name} #{last_name}"
  end
end
