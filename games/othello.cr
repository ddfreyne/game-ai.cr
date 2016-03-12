class Othello < Game
  def initialize(grid = nil, @skips = {} of Symbol => Bool)
    @grid = grid || {
      {3, 3} => :black,
      {4, 4} => :black,
      {4, 3} => :white,
      {3, 4} => :white,
    }

    @_moves = {} of Symbol => Array(Move)
  end

  def new_human_player(player_color)
    HumanOthelloPlayer.new(player_color)
  end

  ###

  def over?(player_color)
    if filled?
      true
    elsif valid_moves(player_color).empty?
      previously_skipped?(player_color)
    else
      false
    end
  end

  def winner
    count(:white) > count(:black) ? :white : :black
  end

  def valid_moves(player_color)
    all_moves_for(player_color).select { |m| valid_move?(m) }
  end

  def valid_move?(move)
    verify_move(move) do |move|
      if self[move.x, move.y]
        false
      else
        cast_rays(move.x, move.y).any? { |ray| valid_ray?(ray, move.color) }
      end
    end
  end

  def verify_move(move)
    case move
    when OthelloMove
      yield move
    else
      raise ArgumentError.new("Wrong move class: #{move.class}")
    end
  end

  def apply_move(move, player_color)
    verify_move(move) do |move|
      new_grid = @grid.merge({ {move.x, move.y} => move.color })

      valid_rays =
        cast_rays(move.x, move.y).select{ |ray| valid_ray?(ray, move.color) }
      valid_rays.each do |ray|
        ray.each do |pair|
          break if @grid[pair] == move.color
          new_grid[pair] = move.color
        end
      end

      self.class.new(new_grid, @skips.merge({ player_color => false }))
    end
  end

  def skip_move(player_color)
    self.class.new(@grid, @skips.merge({ player_color => true }))
  end

  ###

  def previously_skipped?(player_color)
    @skips.fetch(player_color, false)
  end

  def filled?
    (0..7).to_a.zip((0..7).to_a) do |x, y|
      return false if self[x, y].nil?
    end
    true
  end

  def [](x : Int32, y : Int32)
    raise ArgumentError.new("x must be 0..7") unless (0..7).includes?(x)
    raise ArgumentError.new("y must be 0..7") unless (0..7).includes?(y)

    @grid[{x, y}]?
  end

  def [](coords : Array)
    if coords.size != 2
      raise ArgumentError.new("expected #coords to be called with two args")
    else
      self[coords[0], coords[1]]
    end
  end

  def [](coords : Tuple(Int32, Int32))
    self[coords[0], coords[1]]
  end

  def count(color)
    @grid.values.count { |v| v == color }
  end

  DIFFS =
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

  def cast_rays(x, y)
    DIFFS.map { |ray| cast_ray(x, y, ray[0], ray[1]) }
  end

  def cast_ray(x, y, fx, fy)
    ray = Array(Tuple(Int32, Int32)).new(8)

    nx = x + fx
    ny = y + fy
    loop do
      break if nx < 0 || nx > 7 || ny < 0 || ny > 7

      ray << {nx, ny}

      nx += fx
      ny += fy
    end

    ray
  end

  def valid_ray?(ray, color)
    return false if ray.size < 2

    chunks = [
      [ray[0]],
    ]

    ray[1..-1].each do |pair|
      if self[chunks.last.last] != self[pair]
        chunks << [pair]
      else
        chunks.last << pair
      end
    end

    chunks.size >= 2 && self[chunks[0][0]] == invert_color(color) && self[chunks[1][0]] == color
  end

  def invert_color(color)
    case color
    when :black
      :white
    when :white
      :black
    else
      raise ArgumentError.new("invalid color: #{color}")
    end
  end

  def all_moves_for(color)
    @_moves[color] ||=
      (0..7).flat_map do |x|
        (0..7).map do |y|
          OthelloMove.new(x, y, color)
        end
      end
  end

  def to_s(io)
    io << "   A  B  C  D  E  F  G  H"
    io << "\n"
    (0..7).each do |y|
      io << "12345678"[y]
      io << ' '
      io << "\e[42m"
      (0..7).each do |x|
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
    io << "\n"
  end
end

struct OthelloMove < Move
  getter :x
  getter :y
  getter :color

  def initialize(x, y, color)
    @x = x
    @y = y
    @color = color
  end

  def inspect
    "Othello:Move(#{x}, #{y}, #{color})"
  end

  def to_s(io)
    io << ('A'..'H').to_a[x] + ('0'..'7').to_a[y]
  end
end

class HumanOthelloPlayer < Player
  def next_move(game)
    loop do
      print "#{@color}’s move? (e.g. A3) "
      raw_line = gets
      if raw_line
        line = raw_line.strip
        match = line.match(/\A(\w)(\d)\z/)
        if match
          if !("A".."H").includes?(match[1].upcase) || !(1..8).includes?(match[2].to_i)
            puts "Invalid input: needs to be in the format “A3”."
          else
            move = OthelloMove.new(match[1].upcase[0].ord - 'A'.ord, match[2].to_i - 1, @color)

            if game.valid_move?(move)
              break move
            else
              puts "Invalid move!"
            end
          end
        else
          puts "Invalid input: needs to be in the format “A3”."
        end
      else
        puts "Invalid input."
      end
    end
  end
end
