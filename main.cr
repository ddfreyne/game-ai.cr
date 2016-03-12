require "./game"
require "./player"
require "./ui"
require "./runner"
require "./othello"

i = 0
loop do
  print "Game #{i}… "
  before = Time.now
  result = Runner.new(SilentUI.new, Othello.new).play
  after = Time.now
  puts "#{result.to_s} (#{after - before}s)"
  i += 1
end
