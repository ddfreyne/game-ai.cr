class Game
end

class Othello < Game
  def initialize(grid = nil)
    @grid = grid || {
      {3, 3} => :black,
      {4, 4} => :black,
      {4, 3} => :white,
      {3, 4} => :white,
    }

    @_moves = {} of Symbol => Array(Move)
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

  def filled?
    (0..7).to_a.zip((0..7).to_a) do |x, y|
      return false if self[x, y].nil?
    end
    true
  end

  def count(color)
    @grid.values.count { |v| v == color }
  end

  def valid_move?(move)
    if self[move.x, move.y]
      false
    else
      cast_rays(move.x, move.y).any? { |ray| valid_ray?(ray, move.color) }
    end
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
          Move.new(x, y, color)
        end
      end
  end

  def valid_moves(color)
    all_moves_for(color).select { |m| valid_move?(m) }
  end

  def apply_move(move)
    new_grid = @grid.merge({ {move.x, move.y} => move.color })

    valid_rays =
      cast_rays(move.x, move.y).select{ |ray| valid_ray?(ray, move.color) }
    valid_rays.each do |ray|
      ray.each do |pair|
        break if @grid[pair] == move.color
        new_grid[pair] = move.color
      end
    end

    self.class.new(new_grid)
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

struct Move
  getter :x
  getter :y
  getter :color

  def initialize(x, y, color)
    @x = x
    @y = y
    @color = color
  end

  def inspect
    "Move(#{x}, #{y}, #{color})"
  end

  def to_s(io)
    io << ('A'..'H').to_a[x] + ('0'..'7').to_a[y]
  end
end

class Player
  getter :color

  def initialize(color)
    @color = color
  end

  def next_move(game)
    raise "Not implemented"
  end
end

class HumanPlayer < Player
  def next_move(game)
    loop do
      print "#{@color}’s move? (e.g. A3) "
      raw_line = gets
      if raw_line
        line = raw_line.strip
        if line !~ /\A(\w)(\d)\z/
          puts "Invalid input: needs to be in the format “A3”."
        elsif !('A'..'H').includes?($1.upcase) || !(1..8).includes?($2.to_i)
          puts "Invalid input: needs to be in the format “A3”."
        else
          move = Move.new($1.upcase.ord - 'A'.ord, $2.to_i - 1, @color)

          if game.valid_move?(move)
            break move
          else
            puts "Invalid move!"
          end
        end
      else
        puts "Invalid input."
      end
    end
  end
end

class RandomPlayer < Player
  def next_move(game)
    game.valid_moves(color).sample
  end
end

class AIPlayer < Player
  def next_move(game)
    players = [
      RandomPlayer.new(:white),
      RandomPlayer.new(:black),
    ]

    game.valid_moves(color).max_by do |move|
      runner = Runner.new(SilentUI.new, game.apply_move(move), players)
      num_wins = (0...20).count { runner.play == color }
      num_wins
    end
  end
end

class UI
  def before_move(player, game)
    raise "Not implemented"
  end

  def after_move(player, game)
    raise "Not implemented"
  end

  def announce_winner(color)
    raise "Not implemented"
  end
end

class HumanUI < UI
  def before_move(player, game)
    puts game
  end

  def after_move(player, game)
    puts
  end

  def announce_winner(color)
    puts "#{color} wins!"
  end
end

class SilentUI < UI
  def before_move(player, game)
  end

  def after_move(player, game)
  end

  def announce_winner(color)
  end
end

class Runner
  # FIXME: pass in which game
  def initialize(ui : UI, game = Othello.new, players = nil)
    @ui = ui
    @game = game

    @players = players || [
      RandomPlayer.new(:white),
      AIPlayer.new(:black),
    ]
  end

  def play
    game = @game

    skipped_turns = {
      white: false,
      black: false,
    }

    loop do
      @players.each do |player|
        @ui.before_move(player, game)

        if game.filled?
          winner = game.count(:white) > game.count(:black) ? :white : :black
          @ui.announce_winner(winner)
          return winner
        elsif game.valid_moves(player.color).empty?
          if skipped_turns[player.color]
            winner = game.invert_color(player.color)
            @ui.announce_winner(winner)
            return winner
          else
            skipped_turns[player.color] = true
          end
        else
          skipped_turns[player.color] = false
          game = game.apply_move(player.next_move(game))
          @ui.after_move(player, game)
        end
      end
    end
  end
end

i = 0
loop do
  print "Game #{i}… "
  before = Time.now
  result = Runner.new(SilentUI.new).play
  after = Time.now
  puts "#{result.to_s} (#{after - before}s)"
  i += 1
end
