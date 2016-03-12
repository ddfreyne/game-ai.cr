class Player
  getter :color

  def initialize(color)
    @color = color
  end

  def next_move(game)
    raise "Not implemented"
  end
end

class RandomPlayer < Player
  def next_move(game)
    game.valid_moves(color).sample
  end
end

class AIPlayer < Player
  def initialize(color, strength)
    super(color)
    @strength = strength
  end

  def next_move(game)
    players = [
      RandomPlayer.new(:white),
      RandomPlayer.new(:black),
    ]

    game.valid_moves(color).max_by do |move|
      runner = Runner.new(SilentUI.new, game.apply_move(move, self.color), players)
      num_wins = (0...@strength).count { runner.play == color }
      num_wins
    end
  end
end
