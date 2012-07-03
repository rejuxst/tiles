
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
	tt = Thing.new(:ASCII => 'X');
	tt.add_to_db Thing.new(:ASCII => '$')
	$thisgame.map.tile(1,1)  << tt
	# print "#{$thisgame.map.tile(10,10).things.length},#{$thisgame.map.tile(1,1).things.length}"
	sleep(2)
	$thisgame.start
	$thisgame.run
	$thisgame.stop
ensure
	print "Waiting for input to close\n"
	Ncurses.stdscr.getch
	Ncurses.endwin
	tt.db_dump.write()

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
end
def require_from_source
	#Dir.chdir(File.join("..","..","lib"))
	core = File.join(File.dirname(__FILE__),"..","..","lib")
	Dir.open(core) do |ent|
		ent.entries.each do |f|
			unless File.directory?(File.join(core,f)) || !(f.match(/\.gitignore/).nil?) || !(f.match(/\.swp/).nil?)
				succ = gem_original_require File.expand_path File.join(ent.to_path,f.partition('.')[0])
				puts "Requiring lib file: #{File.join(f.partition('.')[0])} => #{succ}"
			end
		end
	end
	# Object.constants().sort.each do |const|
		 # puts const unless const.is_a?(Array)||!@oldobj.index(const).nil?
	# end
end
begin
	require_from_source
	#require_loop
	run
end

