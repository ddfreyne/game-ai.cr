require "./game"
require "./move"
require "./player"
require "./ui"
require "./runner"
require "./games/othello"
require "./games/connect-four"

i = 0
loop do
  print "Game #{i}… "
  before = Time.now
  result = Runner.new(HumanUI.new, ConnectFour.new).play
  after = Time.now
  puts "#{result.to_s} (#{after - before}s)"
  i += 1
end
