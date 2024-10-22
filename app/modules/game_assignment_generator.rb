module GameAssignmentGenerator
  def generate_player_game_assignments(player_game_assignments, number_of_innings)
    (1..number_of_innings).each do |inning|
      inning_index = inning - 1

      FieldingPosition.high_priority.pluck(:name).shuffle.each do |hi_pos|
        assign_position(player_game_assignments, hi_pos, inning_index)
      end

      FieldingPosition.medium_priority.pluck(:name).shuffle.each do |med_pos|
        assign_position(player_game_assignments, med_pos, inning_index)
      end

      FieldingPosition.low_priority.pluck(:name).shuffle.each do |low_pos|
        assign_position(player_game_assignments, low_pos, inning_index)
      end
    end

    player_game_assignments
  end

  def assign_position(player_game_assignments, position, inning_index)
    player_ids = available_players(player_game_assignments, position, inning_index)
    return if player_ids.empty?

    selected_player_id = player_ids.shuffle.first
    player_game_assignments.find { |a| a[:player_id] == selected_player_id }[:game_assignments][inning_index] = position
  end
end
