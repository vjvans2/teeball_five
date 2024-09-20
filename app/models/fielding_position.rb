# == Schema Information
#
# Table name: fielding_positions
#
#  id             :bigint           not null, primary key
#  hierarchy_rank :integer
#  name           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class FieldingPosition < ApplicationRecord
  INFIELD_POSITIONS = %w[1B 2B 3B SS P C]
  OUTFIELD_POSITIONS = %w[LF LC RC RF]

  scope :infield, -> { where(name: INFIELD_POSITIONS) }
  scope :outfield, -> { where(name: OUTFIELD_POSITIONS) }

  scope :high_priority, -> { where(hierarchy_rank: 1) }
  scope :medium_priority, -> { where(hierarchy_rank: 2) }
  scope :low_priority, -> { where(hierarchy_rank: 3) }
end
