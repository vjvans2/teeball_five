class GetRandomPosition
  attr_reader :positions, :picked_positions
  def initialize(picked_positions = [])
    @positions = FieldingPosition.all.map(&:name)
    @picked_positions = picked_positions
  end

  def choose_and_remove
    return nil if available_positions.empty?

    selected_position = available_positions.sample

    if is_valid_choice?(selected_position)
      @positions.delete(selected_position)
      @picked_positions = []

      selected_position
    else
      @picked_positions << selected_position
      choose_and_remove
    end
  end

  private

  def available_positions
    @positions - @picked_positions
  end

  def is_valid_choice?(selected_position)
    p "selected position in is_valid_choice ---- #{selected_position}"
    true
  end
end
