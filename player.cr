class Player
  getter :color

  def initialize(color)
    @color = color
  end

  def next_move(game)
    raise "Not implemented"
  end

  def opponent_color
    case color
    when :black
      :white
    when :white
      :black
    else
      raise "Unknown color: #{color.inspect}"
    end
  end
end

class RandomPlayer < Player
  def next_move(game)
    game.valid_moves(color).sample
  end
end

class RandomPickWinningPlayer < Player
  def next_move(game)
    moves = game.valid_moves(color)
    best_move =
      moves.find do |move|
        new_game = game.apply_move(move, color)
        new_game.over?(color) && new_game.winner == color
      end

    if best_move
      best_move
    else
      moves.sample
    end
  end
end

class AIPlayer < Player
  def initialize(color, strength)
    super(color)
    @strength = strength
  end

  def next_move(game)
    game.valid_moves(color).max_by do |move|
      runner = Runner.new(SilentUI.new, game.apply_move(move, self.color), players)
      num_wins = (0...@strength).count { runner.play == color }
      num_wins
    end
  end

  def players
    [
      RandomPlayer.new(opponent_color),
      RandomPlayer.new(color),
    ]
  end
end

class SmarterAIPlayer < AIPlayer
  def players
    [
      RandomPickWinningPlayer.new(opponent_color),
      RandomPickWinningPlayer.new(color),
    ]
  end
end
