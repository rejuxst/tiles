### MAIN LOOP ###
$LOAD_PATH << File.absolute_path(File.join(File.dirname(__FILE__),'/../../lib/'))
require 'launcher'
Tiles::Launcher.launch( "Crawl", 
		:debug => true, 
		:load_source => :source, :source_dir => File.join(Dir.pwd,'lib') , 
		:app_dir => File.join(Dir.pwd,'test','testapp')	,
		:safe_level => 0
		) do |game|
	$thisgame = game
	game.players << SuperHuman_DEBUG.new( :ui => Ncurses::UI.new )
	game.players[0].take_control Character.new(:ASCII => '@'), :reference => "character"
	game.map.tile(10,10).add_to_db game.players[0].character
#	game.views << game.players[0].ui
end 

