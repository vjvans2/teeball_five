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

  def is_valid_choice?(assignments, selected_position, player_id)
    all_player_previous_game_assignments = assignments.find { |a| a[:player_id] == player_id }[:previous_assignments]

    return true if @current_inning_index == 0 && all_player_previous_game_assignments.empty?

    current_player_game = current_player_game_assignments(player_id)

    # have you played this {selected_position} already this game?
    return false if current_player_game[:game_positions].include?(selected_position)

    # is {selected_position} P and you've already been 1B this game?
    return false if current_player_game[:game_positions].include?("P") && selected_position == "1B"

    # is {selected_position} 1B and you've already been P this game?
    return false if current_player_game[:game_positions].include?("1B") && selected_position == "P"

    # is {selected_position} in the outfield and you already played two outfield innings this game?
    return false if current_player_game[:full_outfield?] && @outfield_positions.include?(selected_position)

    true
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

# klass = GenerateGameAssignmentsService.new(GamedayTeam.last)
# player_game_assignments = klass.send(:initial_assignments)
# klass.send(:generate_inning_assignments, 0, player_game_assignments)
