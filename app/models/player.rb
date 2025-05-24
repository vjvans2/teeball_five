# == Schema Information
#
# Table name: players
#
#  id             :bigint           not null, primary key
#  assist_out     :bigint           default(0), not null
#  direct_out     :bigint           default(0), not null
#  first_name     :string
#  homeruns       :bigint           default(0), not null
#  jersey_number  :integer
#  last_name      :string
#  leadoffs       :bigint           default(0), not null
#  postgame_cheer :bigint           default(0), not null
#  sat_out        :bigint           default(0), not null
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

  validates :team_id, presence: true
  validates :first_name, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end

  def gameday_player_label_name
    "##{jersey_number} -- #{first_name}"
  end

  def safe_decrement!(property)
    # Check if the property exists and is a valid numeric field
    if self.respond_to?(property) && self.send(property).is_a?(Numeric)
      current_value = self.send(property)
      # Decrement only if the current value is greater than 0
      if current_value > 0
        self.update(property => [ current_value - 1, 0 ].max)
      end
    else
      raise ArgumentError, "Invalid property or not a numeric field"
    end
  end

  def player_assignments_to_revise
    assignments = []
    player_innings.group_by(&:game_id).map do |game_id, pi|
      assigned = pi.map do |record|
        {
          inning: record.inning.inning_number,
          fielding_position_id: record.fielding_position_id,
          fielding_position_name: record.fielding_position.name
        }
      end

      assignments << {
        game_id:,
        assigned:
      }
    end

    assignments
  end
end
