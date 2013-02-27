### MAIN LOOP ###
$LOAD_PATH << File.absolute_path(File.join(File.dirname(__FILE__),'/../../lib/'))
require 'tiles'
Tiles::Launcher.launch( "Crawl", 
		:debug => true, 
		:load_source => :source, :source_dir => File.join(Dir.pwd,'lib') , 
		:app_dir => File.join(Dir.pwd,'test','testapp')	,
		:safe_level => 0
		) do |game,app|
	game.players << SuperHuman_DEBUG.new( :ui => SuperHuman_DEBUG::UI.new )
	game.players[0].take_control Character.new(:ASCII => '@'), :reference => "character"
	game.map.tile(10,10).add_to_db game.players[0].character
	app.register_new_channel_class  Channel.name
	app.register_new_channel_class  SuperHuman_DEBUG::Channel.name
	app.register_view 		SuperHuman_DEBUG::View.new(:game => game, :player => game.players[0]) 
	app.register_channel_to  	SuperHuman_DEBUG::Channel.new(), game.players[0].ui
end 

