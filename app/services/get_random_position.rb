class GetRandomPosition
  def initialize
    @positions = FieldingPosition.all.map(&:name)
  end

  def choose_and_remove
    return nil if @positions.empty?

    random = @positions.sample
    @positions.delete(random)
    p "random --- #{random}"
    random
  end
end
