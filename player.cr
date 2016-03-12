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
      runner = Runner.new(SilentUI.new, game.apply_move(move, self.color), players)
      num_wins = (0...10).count { runner.play == color }
      num_wins
    end
  end
end
