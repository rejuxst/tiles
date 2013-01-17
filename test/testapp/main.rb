require 'pry'
def run
filedir = File.dirname(File.absolute_path(__FILE__))
gem_original_require File.join(filedir,"app/maps/dungeon") #"app/maps/dungeon"
gem_original_require File.join(filedir,"app/games/crawl")
gem_original_require File.join(filedir,"app/tiles/ground")
gem_original_require File.join(filedir,"app/tiles/water")
gem_original_require File.join(filedir,"app/tiles/wall")
gem_original_require File.join(filedir,"app/actions/move")
gem_original_require File.join(filedir,"app/players/human")
# Initialize Game
$thisgame = Crawl.new
$thisgame.players << SuperHuman_DEBUG.new() #:ui => Ncurses::UI.new
$thisgame.map.tile(10,10).add_to_db Actor.new(:ASCII => '@', :controller => $thisgame.players[0])
tt = Thing.new(:ASCII => 'X');
tt.add_to_db Thing.new(:ASCII => '$')
$thisgame.map.tile(1,1).add_to_db tt

#	sleep(2)
#	Start Game
$thisgame.start
$thisgame.run
$thisgame.stop
ensure
#binding.pry
#Ncurses.getch
#Ncurses.close_screen
puts $thisgame.players if $thisgame.class <= Game


end
def require_from_source
$LOAD_PATH << File.absolute_path(File.join(File.dirname(__FILE__),'/../../lib/'))
core = File.join(File.dirname(__FILE__),"..","..","lib")
#puts "$LOAD_PATH LIST:"
#puts $LOAD_PATH
Dir.open(core) do |ent|
	ent.entries.each do |f|
	unless File.directory?(File.join(core,f)) || !(f.match(/\.gitignore/).nil?) || !(f.match(/\.swp/).nil?)
		succ = gem_original_require File.expand_path(File.join(ent.to_path,f.partition('.')[0]))
		puts "Requiring lib file: #{File.join(f.partition('.')[0])} => #{succ}"	
	end
	end
end
rescue 
	binding.pry
end
### MAIN LOOP ###
begin
	require_from_source
	require 'mixins/ncurses/ncurses_ui'
	run
end
