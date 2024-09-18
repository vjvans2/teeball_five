class GetRandomPosition
  attr_reader :all_positions, :positions, :picked_positions, :assignments,
  :current_inning_index, :outfield_positions

  def initialize(assignments, current_inning_index, picked_positions = [])
    @all_positions = FieldingPosition.all.pluck(:name)
    @volatile_positions = FieldingPosition.all.pluck(:name)
    @assignments = assignments
    @current_inning_index = current_inning_index
    @picked_positions = picked_positions
    @outfield_positions = FieldingPosition.outfield.pluck(:name)
    @infield_positions = FieldingPosition.infield.pluck(:name)
  end

  def choose_and_remove(player_id)
    return nil if available_positions.empty?

    selected_position = available_positions.sample

    if is_valid_choice?(selected_position, player_id)
      @volatile_positions.delete(selected_position)
      @picked_positions = []

      selected_position
    else
      @picked_positions << selected_position
      choose_and_remove(player_id)
    end
  end

  def is_valid_inning?
    # does the "complete" inning have all 10 primary positions covered?
    # what about a >10 or <10 scenario?
    inning_assignments = @assignments.map { |a| a[:game_assignments][current_inning_index] }
    inning_assignments.all? do |inning_assignment|
      @all_positions.include?(inning_assignment)
    end
  end

  private

  def available_positions
    @volatile_positions - @picked_positions
  end

  def is_valid_choice?(selected_position, player_id)
    all_player_previous_game_assignments = @assignments.find { |a| a[:player_id] == player_id }[:previous_assignments]

    return true if @current_inning_index == 0 && all_player_previous_game_assignments.empty?

    # will need outfield love eventually
    # are you assigned {selected_infield_position}, but you played there last game?
    return false if played_that_infield_position_last_game?(selected_position, all_player_previous_game_assignments.last)

    # are you assigned {selected_infield_position}, but not everybody on the team has played there {minimum_amount_of_times} yet?
    return false if other_teammates_have_not_played_there_equally_yet?(selected_position, player_id)

    current_player_game = current_player_game_assignments(player_id)

    # have you played this {selected_position} already this game?
    return false if current_player_game[:game_positions].include?(selected_position)

    # is {selected_position} P and you've already been 1B this game?
    return false if current_player_game[:game_positions].include?("P") && selected_position == "1B"

    # is {selected_position} 1B and you've already been P this game?
    return false if current_player_game[:game_positions].include?("1B") && selected_position == "P"

    # is {selected_position} in the outfield and you already played two outfield innings this game?
    return false if current_player_game[:full_outfield?] && @outfield_positions.include?(selected_position)

    # has player already played two positions in the infield in this game?
    # return false if current_player_game[:full_infield?] && @infield_positions.include?(selected_position)

    # is {selected_position} LF/LC, but you played LF/LC in a previous inning?
    # is {selected_position} RF/RC, but you played RF/RC in a previous inning?

    true
  end

  def played_that_infield_position_last_game?(selected_position, players_last_game)
    return false if players_last_game.nil? || players_last_game.empty?
    return false if @outfield_positions.include?(selected_position)

    players_last_game_positions = players_last_game[:game_assignments].map { |plg| plg[:position] } - @outfield_positions
    players_last_game_positions.include?(selected_position)
  end

  def other_teammates_have_not_played_there_equally_yet?(selected_position, player_id)
    return false if @assignments.all? { |a| a[:previous_assignments].nil? }

    return false if @outfield_positions.include?(selected_position)

    # count up how many of the players have played that position
    # if current player isn't in that list, then return true: other players need to be this position before they can again.
    return true unless player_ids_in_line_to_play_position(selected_position).include?(player_id)

    false
  end

  def player_ids_in_line_to_play_position(selected_position)
    # returns an array of hashes where the player_id is matched with how many total times they've played {selected_position}
    player_count_hash_array = @assignments.map do |a|
      pos_count = 0
      a[:previous_assignments].each do |pa|
        if pa[:game_assignments].any? { |ga| ga[:position] == selected_position }
          pos_count = pos_count + 1
        end
      end
      { player_id: a[:player_id], pos_count: pos_count }
    end

    # group_by count
    # map the values to new hashes where the count and values are in same hash
    # sort from least to biggest
    # get first to get the lowest entries and/or non-players in that position
    # sort for cleanliness
    player_count_hash_array
      .group_by { |data| data[:pos_count] }
      .map { |k, v| { count: k, player_ids: v.map { |h| h[:player_id] } } }
      .sort_by { |gb| gb[:count] }
      .first[:player_ids]
      .sort
  end

  def current_player_game_assignments(player_id)
    player_flat_array = @assignments.find { |a| a[:player_id] == player_id }[:game_assignments]
    {
      game_positions: player_flat_array,
      full_outfield?: (@outfield_positions & player_flat_array).size == 2,
      full_infield?: (@infield_positions & player_flat_array).size === 3
    }
  end
end
