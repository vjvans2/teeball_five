module PlayersAvailable
  include Loggable

  def available_players(player_game_assignments, selected_position, inning_index, override_log, override_counter)
    already_placed = players_with_a_position_this_inning(player_game_assignments, inning_index)

    return [] if already_placed.size == player_game_assignments.size

    eligible_players = player_ids_in_line_to_play_position(selected_position, player_game_assignments, already_placed)
    filter_valid_players(player_game_assignments, eligible_players, selected_position, inning_index)
  end

  def filter_valid_players(player_game_assignments, player_ids, position, inning_index)
    valid_players = []
    invalid_players = []
    player_ids.each do |player_id|
      player_assignment = player_game_assignments.find { |pga| pga[:player_id] == player_id }
      validation = is_valid_choice?(player_assignment, position, inning_index)

      if validation[:valid]
        valid_players << player_id
      else
        invalid_players << { player_id: player_id, reason: validation[:reason], position: position }
      end
    end

    if valid_players.empty?
      nil
    else
      valid_players
    end
  end

  def players_with_a_position_this_inning(player_game_assignments, inning_index)
    player_game_assignments
      .select { |player| player[:game_assignments][inning_index].present? }
      .map { |x| x[:player_id] }
  end

  def player_ids_in_line_to_play_position(selected_position, player_game_assignments, already_placed)
    # returns an array of hashes where the player_id is matched with how many total times they've played {selected_position}
    player_count_hash_array = player_game_assignments.map do |pga|
      position_count = 0
      pga[:previous_assignments].each do |pa|
        if pa[:game_assignments].any? { |ga| ga[:position] == selected_position }
          position_count = position_count + 1
        end
      end

      if pga[:game_assignments].include?(selected_position)
        position_count = position_count + 1
      end

      { player_id: pga[:player_id], position_count: position_count }
    end

    # group_by count
    # map the values to new hashes where the count and values are in same hash
    # sort from least to biggest
    # get first to get the lowest entries and/or non-players in that position
    # sort for cleanliness
    sorted_player_counts = player_count_hash_array
      .group_by { |data| data[:position_count] }
      .map { |count, player_id_values| { count: count, player_ids: player_id_values.map { |h| h[:player_id] } } }
      .sort_by { |grouped_mapped_data| grouped_mapped_data[:count] }


    # there are instances where the player whose turn it is was assigned another position earlier this inning, skip and it'll work itself out
    return_me = []
    sorted_player_counts.each do |counts|
      if (counts[:player_ids] - already_placed).empty?
        next
      else
        return_me = counts[:player_ids] - already_placed
        break
      end
    end

    return_me
  end

  def is_valid_choice?(player_assignments, selected_position, inning_index)
    return { valid: true, reason: nil } if inning_index == 0 && player_assignments[:previous_assignments].empty?

    current_player_game = current_player_game_assignments(player_assignments)
    infield_positions = FieldingPosition.infield.pluck(:name)
    selected_is_infield = infield_positions.include?(selected_position)
    last_inning_position = current_player_game[:game_positions][inning_index - 1]

    return { valid: false, reason: "repeat infield position" } if selected_is_infield && current_player_game[:game_positions].include?(selected_position)
    return { valid: false, reason: "out two innings in a row" } if last_inning_position == "_OUT_" && selected_position == "_OUT_"
    # return { valid: false, reason: "if outfield,can\'t be outfield again" } if selected_position == "OF" && last_inning_position == "OF"
    return { valid: false, reason: "if P, can't also be 1B" } if current_player_game[:game_positions].include?("1B") && selected_position == "P" && inning_index < 4
    return { valid: false, reason: "if 1B, can't also be P" } if current_player_game[:game_positions].include?("P") && selected_position == "1B" && inning_index < 4
    return { valid: false, reason: "full_infield" } if current_player_game[:full_infield?] && selected_is_infield
    return { valid: false, reason: "full_outfield" } if current_player_game[:full_outfield?] && selected_position == "OF"

    { valid: true, reason: nil }
  end

  def current_player_game_assignments(player_assignments)
    player_flat_array = player_assignments[:game_assignments]
    infield_positions = FieldingPosition.infield.pluck(:name)
    {
      game_positions: player_flat_array,
      full_infield?: (infield_positions & player_flat_array).size == 4,
      full_outfield?: player_flat_array.count("OF") == 3
    }
  end
end
