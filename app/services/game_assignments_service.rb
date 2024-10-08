class GameAssignmentsService
  attr_reader :gameday_team, :number_of_gameday_players, :number_of_innings, :override_log, :override_counter
  def initialize(gameday_team, num_innings = 4)
    @gameday_team = gameday_team
    @number_of_gameday_players = gameday_team.gameday_players.size
    @number_of_innings = num_innings
    @override_log = []
    @override_counter = 0
  end

  def generate_game_assignments
    assignments = generate_player_game_assignments(initial_assignments)

    write_overrides_to_log

    save_player_inning_assignments(assignments)
    save_player_counters(assignments)

    assignments
  end

  def retrieve_prior_game_assignments(game_id)
      flat_player_innings = @gameday_team.gameday_players.sort_by { |player| player[:jersey_number] }.map do |gameday_player|
      gameday_player.player_innings.select { |gdpi| gdpi[:game_id] == game_id }
      end.flatten

      flat_player_innings.group_by(&:player_id)
      .map do |player_id, innings|
        {
          player: {
            name:  Player.find(player_id).full_name,
            jersey_number: Player.find(player_id).jersey_number
          },
          batting_order: innings.first.batting_order,
          game_assignments: innings.map do |inning|
            {
              inning_number: inning.inning.inning_number,
              position: inning.fielding_position.name
            }
          end
        }
      end.sort_by { |x| x[:batting_order] }
  end

  private


  def initial_assignments
    list = Array.new(@number_of_gameday_players)
    empty_innings = Array.new(@number_of_innings) { nil }

    # shuffle_by_leadoff to get the primary leadoffs/hr
    # but still need to do a check on the 10th/final batter to get the non-leadoff-hr
    GamedayPlayer.shuffle_by_leadoff(@gameday_team.gameday_players).each_with_index do |gameday_player, index|
      list[index] = {
        player_id: gameday_player.player_id,
        leadoffs: gameday_player.player.leadoffs,
        homeruns: gameday_player.player.homeruns,
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
      inning_index = inning - 1

      # Pitcher and 1B
      FieldingPosition.high_priority.pluck(:name).shuffle.each do |hi_pos|
        player_ids = available_players(player_game_assignments, hi_pos, inning_index)

        next if player_ids.empty?

        hi_sample = player_ids.shuffle.first
        player_game_assignments.find { |a| a[:player_id] == hi_sample }[:game_assignments][inning_index] = hi_pos
      end
    end

    (1..@number_of_innings).each do |inning|
      inning_index = inning - 1

      # 2B, SS, 3B
      FieldingPosition.medium_priority.pluck(:name).shuffle.each do |med_pos|
        player_ids = available_players(player_game_assignments, med_pos, inning_index)

        next if player_ids.empty?

        med_sample = player_ids.shuffle.first
        player_game_assignments.find { |d| d[:player_id] == med_sample }[:game_assignments][inning_index] = med_pos
      end
    end

    (1..@number_of_innings).each do |inning|
      inning_index = inning - 1

      # remaining players get random outfield (logic on repeats to be added later)
      # Catcher is now tier 3 so that there are 5 "preferred" positions and 5 "lesser".
      FieldingPosition.low_priority.pluck(:name).each do |low_pos|
        player_ids = available_players(player_game_assignments, low_pos, inning_index)

        next if player_ids.empty?

        low_sample = player_ids.shuffle.first
        player_game_assignments.find { |g| g[:player_id] == low_sample }[:game_assignments][inning_index] = low_pos
      end
    end

    player_game_assignments
  end

  def available_players(player_game_assignments, selected_position, inning_index)
    already_placed = players_with_a_position_this_inning(player_game_assignments, inning_index)

    return [] if already_placed.size == player_game_assignments.size

    all = player_ids_in_line_to_play_position(selected_position, player_game_assignments, already_placed)
    players = player_game_assignments.select { |a| (all).include?(a[:player_id]) }
    final = []

    p "--- Inning #{inning_index + 1} --- #{selected_position} --- Potential Players #{players.map { |p| p[:player_id] }}"

    invalid_players = []
    players.each do |player_assignment|
      choice = is_valid_choice?(player_assignment, selected_position, inning_index)
      if choice[:valid]
        final << player_assignment[:player_id]
      else
        game_num = player_assignment[:previous_assignments].empty? ? 1 : player_assignment[:previous_assignments].size + 1
        msg = "--- Game #{game_num}, Inning #{inning_index + 1} --- Player #{player_assignment[:player_id]} INVALID for #{selected_position} because #{choice[:reason]}"

        invalid_players << { player_id: player_assignment[:player_id], msg: msg }
      end
    end

    if final.empty?
      # we're going to use the invalid players and log it as an override
      # eventually, we log this on the player as a "good game" or a "bad game" from scheduling perspective
      invalid_players.each do |ip|
        log =  "---- OVERRIDE ----- #{ip[:msg]}"
        p log
        override_log << log
      end

      @override_counter = @override_counter + 1

      invalid_players.map { |player| player[:player_id] }
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

  def players_with_a_position_this_inning(player_game_assignments, inning_index)
    player_game_assignments
      .select { |player| player[:game_assignments][inning_index].present? }
      .map { |x| x[:player_id] }
  end

  def is_valid_choice?(player_assignments, selected_position, inning_index)
    return { valid: true, reason: nil } if inning_index == 0 && player_assignments[:previous_assignments].empty?

    current_player_game = current_player_game_assignments(player_assignments)

    # have you played this {selected_infield_position} already this game?
    return { valid: false, reason: "repeat position" } if current_player_game[:game_positions].include?(selected_position)

    # TODO ---- handle outfield duplicates and "good game" vs. "bad game" assignments
    # # is {selected_position} in the outfield and you already played two outfield innings this game?
    outfield_positions = FieldingPosition.outfield.pluck(:name)
    return { valid: false, reason: "full_outfield" } if current_player_game[:full_outfield?] && outfield_positions.include?(selected_position)

    # did you play infield last inning, play outfield next

    # is {selected_position} in the infield and you already played two infield innings this game?
    infield_positions = FieldingPosition.infield.pluck(:name)
    return { valid: false, reason: "full_infield" } if current_player_game[:full_infield?] && infield_positions.include?(selected_position)

    { valid: true, reason: nil }
  end

  def current_player_game_assignments(player_assignments)
    player_flat_array = player_assignments[:game_assignments]
    outfield_positions = FieldingPosition.outfield.pluck(:name)
    infield_positions = FieldingPosition.infield.pluck(:name)
    {
      game_positions: player_flat_array,
      full_outfield?: (outfield_positions & player_flat_array).size == 2,
      full_infield?: (infield_positions & player_flat_array).size == 2
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

  def save_player_counters(player_game_assignments)
    # save the leadoffs, homeruns preset from the assignments here

    # grab the players from {gameday_team.team_size_leadoff_homerun_chart} and pluck their player_ids
    # to increment leadoffs and homeruns
    # since 10 players mvp/default
    leadoffs = player_game_assignments.first(4).map { |leadoff| leadoff[:player_id] }
    homeruns = player_game_assignments.first(3).map { |hr| hr[:player_id] }
    homeruns << player_game_assignments.last[:player_id]

    leadoffs.each do |leadoff_player_id|
      Player.find(leadoff_player_id).increment!(:leadoffs)
    end

    homeruns.each do |homerun_player_id|
      Player.find(homerun_player_id).increment!(:homeruns)
    end
  end

  def write_overrides_to_log
    File.open("teeball_log.txt", "a") do |file|
      file.write("TIME ----- #{Time.now.strftime("%B %d, %Y %I:%M %p")}" + "\n")

      @override_log.each do |log|
        file.write(log + "\n")
      end

      file.write("Final Override Counter ---- #{@override_counter}" + "\n")
    end
  end
end
