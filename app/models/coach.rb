# == Schema Information
#
# Table name: coaches
#
#  id                   :bigint           not null, primary key
#  first_name           :string
#  is_head_coach        :boolean
#  last_name            :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  associated_player_id :bigint
#  team_id              :bigint           not null
#
# Indexes
#
#  index_coaches_on_associated_player_id  (associated_player_id)
#  index_coaches_on_team_id               (team_id)
#
# Foreign Keys
#
#  fk_rails_...  (associated_player_id => players.id)
#  fk_rails_...  (team_id => teams.id)
#
class Coach < ApplicationRecord
  belongs_to :team
  belongs_to :associated_player, class_name: "Player", foreign_key: "associated_player_id", optional: true

  def full_name
    "#{first_name} #{last_name}"
  end
end
