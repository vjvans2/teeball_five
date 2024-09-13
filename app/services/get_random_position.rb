class GetRandomPosition
  attr_reader :all_positions, :positions, :picked_positions, :assignments,
  :current_inning_index, :outfield_positions

  def initialize(assignments, current_inning_index, picked_positions = [])
    @all_positions = FieldingPosition.all.map(&:name)
    @volatile_positions = FieldingPosition.all.map(&:name)
    @assignments = assignments
    @current_inning_index = current_inning_index
    @picked_positions = picked_positions
    @outfield_positions = %w[LF LC RC RF]
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
    # we need an @all_positions because a complete inning will have an empty array for @volatile_positions
    inning_assignments = assignments.map { |a| a[:game_assignments][current_inning_index] }
    inning_assignments.all? do |inning_assignment|
      @all_positions.include?(inning_assignment)
    end
  end

  private

  def available_positions
    @volatile_positions - @picked_positions
  end

  def is_valid_choice?(selected_position, player_id)
    # have you played this position already this game?
    # is this P and you've already been 1B?
    # is this 1B and you've already been P?
    # have you already played two outfield innings?
    # TODO: were you out for an inning and need preferential infield treatment?

    return true if @current_inning_index == 0

    player = current_player(player_id)

    return false if player[:game_positions].include?(selected_position)
    return false if player[:game_positions].include?("P") && selected_position == "1B"
    return false if player[:game_positions].include?("1B") && selected_position == "P"
    return false if player[:full_outfield?] && @outfield_positions.include?(selected_position)

    true
  end

  def current_player(player_id)
    # take the vertical index of the 4x11 and give me a flattened array
    # of all of that players current positions and logic this game

    player_flat_array = @assignments.find { |a| a[:player_id] == player_id }[:game_assignments]
    {
      game_positions: player_flat_array,
      full_outfield?: (@outfield_positions & player_flat_array).size == 2
    }
  end
end
