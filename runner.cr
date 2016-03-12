class Runner
  def initialize(ui : UI, game, players = nil)
    @ui = ui
    @game = game

    @players = players || [
      HumanOthelloPlayer.new(:white),
      SmarterAIPlayer.new(:black, 10),
    ]
  end

  def play
    game = @game

    loop do
      @players.each do |player|
        @ui.before_move(player, game)

        if game.over?(player.color)
          winner = game.winner
          @ui.announce_winner(winner)
          return winner
        elsif game.valid_moves(player.color).empty?
          game = game.skip_move(player.color)
        else
          game = game.apply_move(player.next_move(game), player.color)
          @ui.after_move(player, game)
        end
      end
    end
  end
end
