### MAIN LOOP ###
$LOAD_PATH << File.absolute_path(File.join(File.dirname(__FILE__),'/../../lib/'))
require 'launcher'
Tiles::Launcher.launch( "Crawl", 
		:debug => true, 
		:load_source => :source, :source_dir => File.join(Dir.pwd,'lib') , 
		:app_dir => File.join(Dir.pwd,'test','testapp')	,
		:safe_level => 0
		) do |game,manager|
	$thisgame = game
	game.players << SuperHuman_DEBUG.new( :ui => SuperHuman_DEBUG::UI.new )
	game.players[0].take_control Character.new(:ASCII => '@'), :reference => "character"
	game.map.tile(10,10).add_to_db game.players[0].character
	manager.register_new_channel("Channel",Channel.new_channel_creation)
	manager.register_new_channel(	SuperHuman_DEBUG::Channel.name,
					SuperHuman_DEBUG::Channel.new_channel_creation
				)
	manager.create_connection(game.players[0].ui,SuperHuman_DEBUG::Channel.name)
#	game.views << game.players[0].ui
end 

