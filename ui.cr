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
