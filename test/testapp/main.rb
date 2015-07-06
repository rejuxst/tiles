#!/usr/bin/env ruby
## TODO: is this needed anymore?
TILES_GEM_PATH = File.absolute_path(File.join(File.dirname(__FILE__),'/../../lib/'))
$LOAD_PATH << TILES_GEM_PATH

require 'pry'
require 'tiles'
Tiles::Launcher.launch "Crawl",
  debug: true, load_source: :source, source_dir: TILES_GEM_PATH,
  app_dir: File.dirname(__FILE__), safe_level: 0 do |game, app|

  game.players << SuperHuman_DEBUG.new(ui: SuperHuman_DEBUG::UI.new)
  game.players[0].take_control Character.new(:ASCII => '@'), reference: "character"
  game.map.tile(10,10).add_to_db game.players[0].character
	# NOTE: Registration of channel classes should NOT fall in the same context
	#       as the game initialization loop. Probably a security issue and a functional limiter
  app.register_new_channel_class Channel.name
  app.register_new_channel_class SuperHuman_DEBUG::Channel.name
  app.register_view							 SuperHuman_DEBUG::View.new(game: game, player: game.players[0])
  app.register_channel_to				 SuperHuman_DEBUG::Channel.new(), game.players[0].ui
end
