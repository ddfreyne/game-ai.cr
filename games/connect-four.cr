class ConnectFour < Game
  def over?(player_color)
    true
  end

  def winner
    :black
  end

  def valid_moves(player_color)
    [ConnectFourMove.new(2, player_color)]
  end

  def valid_move?(move)
    false
  end

  def apply_move(move, player_color)
    self
  end

  def skip_move(player_color)
    self
  end
end

struct ConnectFourMove < Move
  getter :x
  getter :color

  def initialize(x, color)
    @x = x
    @color = color
  end

  def inspect
    "ConnectFour::Move(#{x}, #{y}, #{color})"
  end

  def to_s(io)
    io << (x + 1).to_s
  end
end
