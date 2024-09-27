class GenerateGameAssignmentsService
  attr_reader :gameday_team, :number_of_gameday_players, :number_of_innings, :iterations
  def initialize(gameday_team, num_innings = 4)
    @gameday_team = gameday_team
    @number_of_gameday_players = gameday_team.gameday_players.size
    @number_of_innings = num_innings
    @iterations = 0
  end

  def generate_game_assignments
    assignments = generate_player_game_assignments(initial_assignments)

    save_player_inning_assignments(assignments)

    assignments
  end

  private

  def initial_assignments
    list = Array.new(@number_of_gameday_players)
    empty_innings = Array.new(@number_of_innings) { nil }

    # "shuffle" will eventually be modified to take into player leadoffs/hrs
    @gameday_team.gameday_players.shuffle.each_with_index do |gameday_player, index|
      list[index] = {
        player_id: gameday_player.player_id,
        game_assignments: empty_innings.dup,
        previous_assignments:  player_previous_assignments(gameday_player)
      }
    end

    list
  end

  def player_previous_assignments(gameday_player)
    gameday_player.player_innings
      .group_by(&:game_id)
      .map do |game_id, innings|
        {
          game_id: game_id,
          batting_order: innings.first.batting_order,
          game_assignments: innings.map do |inning|
            {
              inning_number: inning.inning.inning_number,
              position: inning.fielding_position.name
            }
          end
        }
      end
  end

  def generate_player_game_assignments(player_game_assignments)
    (1..@number_of_innings).each do |inning|
      p "----------- HI FROM GAME #{@gameday_team.game_id}, INNING ##{inning} -----------"

      inning_index = inning - 1

        # Pitcher and 1B
        FieldingPosition.high_priority.pluck(:name).shuffle.each do |hi_pos|
          player_ids = available_players(player_game_assignments, hi_pos, inning_index)

          p "available_players for #{hi_pos} ----------- #{player_ids}"

          hi_sample = player_ids.shuffle.first
          p "hi from hi_sample ----- #{hi_sample}"

          players = player_game_assignments.select { |b| b[:game_assignments][inning_index].nil? }
          p "hi from hi players ---- #{players.map { |p| p[:player_id] }}"

          players.find { |a| a[:player_id] == hi_sample }[:game_assignments][inning_index] = hi_pos
        end

        # Catcher and Infield
        FieldingPosition.medium_priority.pluck(:name).shuffle.each do |med_pos|
          player_ids = available_players(player_game_assignments, med_pos, inning_index)

          p "available_players for #{med_pos} ----------- #{player_ids}"

          med_sample = player_ids.shuffle.first
          p "hi from med_sample ----- #{med_sample}"

          players = player_game_assignments.select { |c| c[:game_assignments][inning_index].nil? }
          p "hi from mid players ---- #{players.map { |p| p[:player_id] }}"

          players.find { |d| d[:player_id] == med_sample }[:game_assignments][inning_index] = med_pos
        end

        # remaining players get random outfield (logic on repeats to be added later)
        FieldingPosition.low_priority.pluck(:name).each do |low_pos|
          players_without_inning_position = player_game_assignments
            .select { |player| player[:game_assignments][inning_index].nil? }
            .map { |x| x[:player_id] }

          p "available_players for #{low_pos} ----------- #{players_without_inning_position}"

          low_sample = players_without_inning_position.shuffle.first
          p "hi from low_sample ----- #{low_sample}"

          players = player_game_assignments.select { |f| f[:game_assignments][inning_index].nil? }
          p "hi from low players ---- #{players.map { |p| p[:player_id] }}"

          players.find { |g| g[:player_id] == low_sample }[:game_assignments][inning_index] = low_pos
        end
  end

    player_game_assignments
  end

  def available_players(player_game_assignments, selected_position, inning_index)
    already_placed = players_with_a_position_this_inning(player_game_assignments, inning_index)
    all = player_ids_in_line_to_play_position(selected_position, player_game_assignments, already_placed)

    players = player_game_assignments.select { |a| (all).include?(a[:player_id]) }
    final = []

    p "--- Inning #{inning_index} --- #{selected_position} --- Potential Players #{players.map { |p| p[:player_id] }}"

    players.each do |player_assignment|
      choice = is_valid_choice?(player_assignment, selected_position, inning_index)
      if choice[:valid]
        final << player_assignment[:player_id]
      else
        p "--- Inning #{inning_index} --- Player #{player_assignment[:player_id]} INVALID for #{selected_position} because #{choice[:reason]}"
      end
    end

    if final.empty?
      egg = "salad"
      binding.pry
      p "egg#{egg}"
    else
      final
    end
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
    if (sorted_player_counts.first[:player_ids] - already_placed).empty?
      sorted_player_counts.second[:player_ids] - already_placed
    else
      sorted_player_counts.first[:player_ids] - already_placed
    end
  end

  def players_with_a_position_this_inning(player_game_assignments, inning_index)
    player_game_assignments
      .select { |player| player[:game_assignments][inning_index].present? }
      .map { |x| x[:player_id] }
  end

  def is_valid_choice?(player_assignments, selected_position, inning_index)
    return {valid: true, reason: nil} if inning_index == 0 && player_assignments[:previous_assignments].empty?

    current_player_game = current_player_game_assignments(player_assignments)

    # TODO ---- handle outfield duplicates

    # have you played this {selected_infield_position} already this game?
    outfield_positions = FieldingPosition.outfield.pluck(:name)
    return {valid: false, reason: "repeat infield"} if (current_player_game[:game_positions] - outfield_positions).include?(selected_position)

    # did you play infield last inning, play outfield next

    # is {selected_position} in the infield and you already played two infield innings this game?
    infield_positions = FieldingPosition.infield.pluck(:name)
    return {valid: false, reason: "full_infield"} if current_player_game[:full_infield?] && infield_positions.include?(selected_position)

    # is {selected_position} in the outfield and you already played two outfield innings this game?
    return {valid: false, reason: "full_outfield"} if current_player_game[:full_outfield?] && outfield_positions.include?(selected_position)

    # # is {selected_position} P and you've already been 1B this game?
    # return false if current_player_game[:game_positions].include?("P") && selected_position == "1B"

    # # is {selected_position} 1B and you've already been P this game?
    # return false if current_player_game[:game_positions].include?("1B") && selected_position == "P"

    {valid: true, reason: nil}
  end

  def current_player_game_assignments(player_assignments)
    player_flat_array = player_assignments[:game_assignments]
    outfield_positions = FieldingPosition.outfield.pluck(:name)
    infield_positions = FieldingPosition.infield.pluck(:name)
    {
      game_positions: player_flat_array,
      full_outfield?: (outfield_positions & player_flat_array).size == 2,
      full_infield?: (infield_positions & player_flat_array).size == 3
    }
  end

  def save_player_inning_assignments(player_game_assignments)
    game_id = @gameday_team.game_id

    (1..@number_of_innings).each do |inning_number|
      inning = Inning.create!(game_id: game_id, inning_number: inning_number)
      player_game_assignments.each_with_index do |player, batting_order_index|
        inning_fielding_position_id = FieldingPosition.find_by_name(player[:game_assignments][inning_number - 1]).id
        PlayerInning.create!(
          player_id: player[:player_id],
          inning_id: inning.id,
          fielding_position_id: inning_fielding_position_id,
          batting_order: batting_order_index + 1,
          game_id: game_id
        )
      end
    end
  end
end
