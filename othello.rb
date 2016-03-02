class Grid
  def initialize(grid = nil)
    @grid = grid || {
      [3, 3] => :black,
      [4, 4] => :black,
      [4, 3] => :white,
      [3, 4] => :white,
    }
  end

  def [](x, y)
    raise ArgumentError, "x must be 0..7" unless (0..7).include?(x)
    raise ArgumentError, "y must be 0..7" unless (0..7).include?(y)

    @grid[[x, y]]
  end

  def valid_move?(move)
    if @grid[[move.x, move.y]]
      false
    else
      cast_rays(move.x, move.y).any? { |ray| valid_ray?(ray, move.color) }
    end
  end

  def cast_rays(x, y)
    diffs =
      [
        [1, 1],
        [1, 0],
        [1, -1],
        [0, -1],
        [-1, -1],
        [-1, 0],
        [-1, 1],
        [0, 1],
      ]

    diffs
      .map { |ray| cast_ray(x, y, ray[0], ray[1]) }
  end

  def cast_ray(x, y, fx, fy)
    bounds = (0..7)

    dxs = (1..7).map { |i| i * fx }
    dys = (1..7).map { |i| i * fy }

    dxs.zip(dys)
      .map { |(dx, dy)| [x+dx, y+dy] }
      .select { |(nx, ny)| bounds.include?(nx) && bounds.include?(ny) }
  end

  def valid_ray?(ray, color)
    ray.size >= 2 &&
      @grid[ray[0]] == invert_color(color) &&
      @grid[ray.chunk_while { |a, b| @grid[a] == @grid[b] }.drop(1).first[0]] == color
  end

  def invert_color(color)
    case color
    when :black
      :white
    when :white
      :black
    else
      raise ArgumentError, "invalid color: #{color}"
    end
  end

  def valid_moves(color:)
    moves =
      (0..7).flat_map do |x|
        (0..7).map do |y|
          Move.new(color: color, x: x, y: y)
        end
      end

    moves.select { |m| valid_move?(m) }
  end

  def apply_move(move)
    new_grid = @grid.merge([move.x, move.y] => move.color)

    valid_rays =
      cast_rays(move.x, move.y).select{ |ray| valid_ray?(ray, move.color) }
    valid_rays.each do |ray|
      ray.each do |(x, y)|
        break if @grid[[x, y]] == move.color
        new_grid[[x, y]] = move.color
      end
    end

    self.class.new(new_grid)
  end

  def to_s
    s = ''
    s << "   A  B  C  D  E  F  G  H"
    s << "\n"
    (0..7).each do |y|
      s << "12345678"[y]
      s << ' '
      s << "\e[42m"
      (0..7).each do |x|
        s << ' '
        s <<
          case self[x, y]
          when :black
            '⚫'
          when :white
            '⚪'
          else
            ' '
          end
        s << ' '
      end
      s << "\e[0m\n"
    end
    s << "\n"
    s
  end
end

class Move
  attr_reader :x
  attr_reader :y
  attr_reader :color

  def initialize(x:, y:, color:)
    @x = x
    @y = y
    @color = color
  end

  def inspect
    "Move(#{x}, #{y}, #{color})"
  end
end

class HumanPlayer
  def initialize(color:)
    @color = color
  end

  def next_move(grid:)
    loop do
      print "#{@color}’s move? (e.g. A3) "
      line = gets.strip
      if line !~ /\A(\w)(\d)\z/
        puts "Invalid input: needs to be in the format “A3”."
      elsif !('A'..'H').include?($1.upcase) || !(1..8).include?($2.to_i)
        puts "Invalid input: needs to be in the format “A3”."
      else
        move = Move.new(x: $1.upcase.ord - 'A'.ord, y: $2.to_i - 1, color: @color)

        if grid.valid_move?(move)
          break move
        else
          puts "Invalid move!"
        end
      end
    end
  end
end

grid = Grid.new

player_a = HumanPlayer.new(color: :white)
player_b = HumanPlayer.new(color: :black)

loop do
  puts grid
  grid = grid.apply_move(player_a.next_move(grid: grid))

  puts grid
  grid = grid.apply_move(player_b.next_move(grid: grid))
end
