require 'pry'
def run
#puts __FILE__
#puts Dir.pwd()
filedir = File.dirname(File.absolute_path(__FILE__))
#File.dirname(File.join(Dir.pwd(),__FILE__))
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
$thisgame.map.tile(10,10) << Actor.new(:ASCII => '@', :controller => $thisgame.players[0])
tt = Thing.new(:ASCII => 'X');
tt.add_to_db Thing.new(:ASCII => '$')
$thisgame.map.tile(1,1)  << tt

#	sleep(2)
#	Start Game
$thisgame.start
$thisgame.run
$thisgame.stop
ensure
print "Waiting for input to close\n"
#Ncurses.getch
#Ncurses.close_screen
puts $thisgame.players if $thisgame.class <= Game
binding.pry
#	tt.db_dump.write()
end

def require_loop
#	@oldobj = Object.constants().sort
#	Dir.chdir(File.join("lib","core"))
#	core = Dir.new(".")
#	core.each do |f|
#		unless File.directory?(File.join(f)) || !(f.match(/\.gitignore/).nil?)
#			succ = require File.join(f.partition('.')[0])
#			#puts "Requiring lib file: #{File.join(f.partition('.')[0])} => #{succ}"
#		end
#	end
#	# Object.constants().sort.each do |const|
#		 # puts const unless const.is_a?(Array)||!@oldobj.index(const).nil?
#	# end
#	Dir.chdir(File.join("..",".."))

require "game"
require "map"
require "tile"
require "action"
require "actor"
require "game"
require "nonactor"
require "generic"
require "player"
require "thing"
require "property"
require "mixins/ncurses/ncurses_ui"
end
def require_from_source
$LOAD_PATH << File.absolute_path(File.join(File.dirname(__FILE__),'/../../lib/'))
core = File.join(File.dirname(__FILE__),"..","..","lib")
puts "$LOAD_PATH LIST:"
puts $LOAD_PATH
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

begin

require_from_source
#require_loop
require 'mixins/ncurses/ncurses_ui'
run
end
