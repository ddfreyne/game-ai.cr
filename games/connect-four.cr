class ConnectFour < Game
  def initialize(grid = nil)
    @grid = grid || {} of Int32 => Bool
  end

  # TODO
  def over?(player_color)
    valid_moves(player_color).empty?
  end

  # TODO
  def winner
    :black
  end

  def valid_moves(player_color)
    possible_moves(player_color).select { |m| valid_move?(m) }
  end

  # TODO
  def valid_move?(move)
    move.x >= 0 && move.x <= 6 && @grid[{move.x, 5}]?.nil?
  end

  def apply_move(move, player_color)
    y = (0..5).find { |cy| @grid[{move.x, cy}]?.nil? }
    self.class.new(@grid.merge({ {move.x, y} => player_color }))
  end

  def skip_move(player_color)
    self
  end

  ###

  def possible_moves(player_color)
    (0..6).map { |x| ConnectFourMove.new(x, player_color) }
  end

  def to_s(io)
    io << " 1  2  3  4  5  6  7 "
    io << "\n"
    (0..5).each do |y|
      y = 5 - y
      io << "\e[42m"
      (0..6).each do |x|
        io << ' '
        io <<
          case self[x, y]
          when :black
            '⚫'
          when :white
            '⚪'
          else
            ' '
          end
        io << ' '
      end
      io << "\e[0m\n"
    end
  end

  def [](x : Int32, y : Int32)
    raise ArgumentError.new("x must be 0..6") unless (0..6).includes?(x)
    raise ArgumentError.new("y must be 0..5") unless (0..5).includes?(y)

    @grid[{x, y}]?
  end

  def [](coords : Tuple(Int32, Int32))
    self[coords[0], coords[1]]
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
