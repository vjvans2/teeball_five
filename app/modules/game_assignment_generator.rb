module GameAssignmentGenerator
  include PlayersAvailable

  def generate_player_game_assignments(player_game_assignments, number_of_innings, override_log, override_counter)
    (1..number_of_innings).each do |inning|
      inning_index = inning - 1

      assign_inning(player_game_assignments, inning_index, override_log, override_counter)

      if player_game_assignments.any? { |pga| pga[:game_assignments][inning_index].nil? }
        player_game_assignments.each { |pga| pga[:game_assignments][inning_index] = nil }
        assign_inning(player_game_assignments, inning_index, override_log, override_counter)
      end
    end

    player_game_assignments
  end

  def assign_inning(player_game_assignments, inning_index, override_log, override_counter)
    num_of_nils = player_game_assignments.size - 10
    if num_of_nils > 0
      Array.new(num_of_nils) { FieldingPosition.nil_position[:name] }.each do |nil_position|
        assign_position(player_game_assignments, nil_position, inning_index, override_log, override_counter)
      end
    end

    Array.new(4) { FieldingPosition.generic_outfield[:name] }.each do |generic_outfield|
      assign_position(player_game_assignments, generic_outfield, inning_index, override_log, override_counter)
    end
    FieldingPosition.high_priority.pluck(:name).shuffle.each do |hi_pos|
      assign_position(player_game_assignments, hi_pos, inning_index, override_log, override_counter)
    end

    FieldingPosition.medium_priority.pluck(:name).shuffle.each do |med_pos|
      assign_position(player_game_assignments, med_pos, inning_index, override_log, override_counter)
    end

    player_game_assignments
  end

  def assign_position(player_game_assignments, position, inning_index, override_log, override_counter)
    player_ids = available_players(player_game_assignments, position, inning_index, override_log, override_counter)

    return if player_ids.nil? || player_ids.empty?

    selected_player_id = player_ids.shuffle.first
    player_game_assignments.find { |a| a[:player_id] == selected_player_id }[:game_assignments][inning_index] = position
    {
      selected_player_id: selected_player_id,
      position: position
    }
  end
end
