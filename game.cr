abstract class Game
  abstract def over?(player_color)
  abstract def winner

  abstract def valid_moves(player_color)
  abstract def valid_move?(move)

  abstract def apply_move(move, player_color)
  abstract def skip_move(player_color)
end
