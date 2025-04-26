module GameAssignmentGenerator
  include PlayersAvailable

  def generate_player_game_assignments(player_game_assignments, number_of_innings, override_log, override_counter)
    (1..number_of_innings).each do |inning|
      inning_index = inning - 1

     begin
      assign_inning(player_game_assignments, inning_index, override_log, override_counter)
     rescue

      binding.pry
      player_game_assignments.each { |pga| pga[:game_assignments][inning_index] = nil }
      assign_inning(player_game_assignments, inning_index, override_log, override_counter)
     end
    end

    player_game_assignments
  end

  def assign_inning(player_game_assignments, inning_index, override_log, override_counter)
    FieldingPosition.high_priority.pluck(:name).shuffle.each do |hi_pos|
      assign_position(player_game_assignments, hi_pos, inning_index, override_log, override_counter)
    end

    FieldingPosition.medium_priority.pluck(:name).shuffle.each do |med_pos|
      assign_position(player_game_assignments, med_pos, inning_index, override_log, override_counter)
    end

    # account for nils and leverage the algorithm to be equitable with them
    num_of_nils = player_game_assignments.size - 10
    if num_of_nils > 0
      Array.new(num_of_nils) { nil }.each do |nil_position|
        assign_position(player_game_assignments, nil_position, inning_index, override_log, override_counter)
      end
    end

    FieldingPosition.low_priority.pluck(:name).shuffle.each do |low_pos|
      assign_position(player_game_assignments, low_pos, inning_index, override_log, override_counter)
    end

    player_game_assignments
  end

  def assign_position(player_game_assignments, position, inning_index, override_log, override_counter)
    player_ids = available_players(player_game_assignments, position, inning_index, override_log, override_counter)

    return if player_ids.empty?

    selected_player_id = player_ids.shuffle.first
    player_game_assignments.find { |a| a[:player_id] == selected_player_id }[:game_assignments][inning_index] = position
    {
      selected_player_id: selected_player_id,
      position: position
    }
  end
end
