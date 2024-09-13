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
end
