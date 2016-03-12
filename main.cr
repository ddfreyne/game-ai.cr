require "option_parser"

require "./game"
require "./move"
require "./player"
require "./ui"
require "./runner"
require "./games/othello"
require "./games/connect-four"

mode = :play
game_name = nil
opponent_strength = 1
self_strength = 1
OptionParser.parse! do |parser|
  parser.banner = "Usage: ./main [arguments]"
  parser.on("-b", "--benchmark", "Benchmark AI") { mode = :benchmark }
  parser.on("-g NAME", "--game=NAME", "Specify game") { |name| game_name = name }
  parser.on("-s VALUE", "--strength=VALUE", "Set opponent strength") { |v| opponent_strength = v.to_i }
  parser.on("-S VALUE", "--self-strength=VALUE", "Set self strength (for --benchmark)") { |v| self_strength = v.to_i }
  parser.on("-h", "--help", "Show this help") { puts parser }
end

unless game_name
  puts "No game specified; pass one with -g/--game."
  exit 1
end

game =
  case game_name.not_nil!.downcase
  when "othello"
    Othello.new
  when "connect-four", "connect four"
    ConnectFour.new
  else
    puts "Unknown game #{game_name}"
    exit 1
  end

case mode
when :play
  players =
    [
      game.new_human_player(:white),
      SmarterAIPlayer.new(:black, opponent_strength),
    ]

  Runner.new(HumanUI.new, game, players).play
when :benchmark
  players =
    [
      SmarterAIPlayer.new(:white, self_strength),
      SmarterAIPlayer.new(:black, opponent_strength),
    ]

  i = 0
  loop do
    print "Game #{i}… "
    before = Time.now
    result = Runner.new(SilentUI.new, game, players).play
    after = Time.now
    puts "#{result.to_s} (#{after - before}s)"
    i += 1
  end
end
