
def run
	filedir = File.dirname(File.join(Dir.pwd(),__FILE__))
	gem_original_require File.join(filedir,"app/maps/dungeon") #"app/maps/dungeon"
	gem_original_require File.join(filedir,"app/games/crawl")
	gem_original_require File.join(filedir,"app/tiles/ground")
	gem_original_require File.join(filedir,"app/tiles/water")
	gem_original_require File.join(filedir,"app/tiles/wall")
	gem_original_require File.join(filedir,"app/actions/move")
	#require "app/games/crawl"
	#require "app/tiles/ground"
	#require "app/tiles/water"
	#require "app/tiles/wall"
	#require "app/actions/move"
	require "mixins/ncurses/ncurses_ui"
	$thisgame = Crawl.new
	$thisgame.players << Player.new(:ui => Ncurses::UI.new)
	$thisgame.map.tile(10,10) << Actor.new(:ASCII => '@', :controller => $thisgame.players[0])
	# print("#{$thisgame.map.tile(10,9).things.length},#{$thisgame.map.tile(10,9).things[0].class}\n")
	$thisgame.map.tile(1,1)  << Thing.new(:ASCII => 'X')
	# print "#{$thisgame.map.tile(10,10).things.length},#{$thisgame.map.tile(1,1).things.length}"
	sleep(2)
	$thisgame.start
	$thisgame.run
	$thisgame.stop
ensure
	Ncurses.endwin
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
end
def require_from_source
	Dir.chdir(File.join("..","source","gem","lib"))
	core = Dir.new(".")
	core.each do |f|
		unless File.directory?(File.join(f)) || !(f.match(/\.gitignore/).nil?)
			succ = require File.join(f.partition('.')[0])
			#puts "Requiring lib file: #{File.join(f.partition('.')[0])} => #{succ}"
		end
	end
	# Object.constants().sort.each do |const|
		 # puts const unless const.is_a?(Array)||!@oldobj.index(const).nil?
	# end
	Dir.chdir(File.join("..","..","..","testspace"))
end
def load_lib
Dir.chdir("..")
lib = Dir.new(File.join("source","gem","lib")); #source/lib
lib.each do |d|
	if !File.directory?(File.join("source","gem","lib",d))
		f = File.open(File.join("source","gem","lib",d),"r")
		fn = File.open(File.join("testspace","lib","core","#{d}"),"w")
		f.each_line{|line| fn.print line}
		f.close
		fn.close
	end
end
Dir.chdir("testspace")
end
def load_mixin(mixin)
Dir.chdir("..")
lib = Dir.new(File.join("source","gem","lib","mixins",mixin)); #source/lib
lib.each do |d|
	if !File.directory?(File.join("source","gem","lib","mixins",mixin,d))
		f = File.open(File.join("source","gem","lib","mixins",mixin,d),"r")
		fn = File.open(File.join("testspace","lib",mixin,"#{d}"),"w")
		f.each_line{|line| fn.print line}
		f.close
		fn.close
	end
end
Dir.chdir("testspace")
end

begin
	#require_from_source
	#load_mixin("ncurses")
	require_loop
	run
end

