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
    begin
      if ray.size <= 2 || @grid[ray[0]] != invert_color(color)
        false
      else
        chunks = ray.chunk_while { |a, b| @grid[a] == @grid[b] }.to_a
        if chunks.size < 2
          false
        else
          @grid[chunks[1][0]] == color
        end
      end
    rescue => e
      p e
      p ray
      p ray.map { |(x, y)| @grid[[x, y]] }
      raise e
    end
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

  def to_s
    ('A'..'H').to_a[x] + ('0'..'7').to_a[y]
  end
end

class Player
  attr_reader :color

  def initialize(color:)
    @color = color
  end

  def next_move(grid:)
    raise NotImplementedError
  end
end

class HumanPlayer < Player
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

class RandomPlayer < Player
  def next_move(grid:)
    grid.valid_moves(color: color).sample
  end
end

class AIPlayer < Player
  def next_move(grid:)
    players = [
      RandomPlayer.new(color: :white),
      RandomPlayer.new(color: :black),
    ]

    best_move =
      grid.valid_moves(color: color).max do |move|
        game = Game.new(ui: SilentUI.new, grid: grid.apply_move(move), players: players)
        num_wins = (0...10).count { game.play == color }
        num_wins
      end

    best_move
  end
end

class UI
  def before_move(player, grid)
    raise NotImplementedError
  end

  def after_move(player, grid)
    raise NotImplementedError
  end

  def announce_winner(color)
    raise NotImplementedError
  end
end

class HumanUI
  def before_move(player, grid)
    puts grid
  end

  def after_move(player, grid)
    sleep 0.1
    puts
  end

  def announce_winner(color)
    puts "#{color} wins!"
  end
end

class SilentUI
  def before_move(player, grid)
  end

  def after_move(player, grid)
  end

  def announce_winner(color)
  end
end

class Game
  def initialize(ui:, grid: Grid.new, players: nil)
    @ui = ui
    @grid = grid

    @players = players || [
      RandomPlayer.new(color: :white),
      AIPlayer.new(color: :black),
    ]
  end

  def play
    grid = @grid
    loop do
      @players.each do |player|
        @ui.before_move(player, grid)
        if grid.valid_moves(color: player.color).empty?
          # FIXME: bad win condition
          winner = grid.invert_color(player.color)
          @ui.announce_winner(winner)
          return winner
        end
        grid = grid.apply_move(player.next_move(grid: grid))
        @ui.after_move(player, grid)
      end
    end
  end
end

p Game.new(ui: HumanUI.new).play
