class Crawl < Game
	def init
		add_reference "map", Dungeon.new, 
			:add_then_reference => :destroy_entry,:if_in_use => :destroy_entry
		add_reference 'eventhandler', Tiles::Application::EventHandler.new(:timespace => Proc.new { |f| f[Fixnum] <=> f[Fixnum] }),
			:add_then_reference => :destroy_entry,:if_in_use => :destroy_entry

	end
	def start
	end
	def inform(source_handler,frame_id)
		run_once
	end
	def process_events
		players.each { |p| p.take_turn if p.turn == turn}
		actors_take_turns	# all uncontrolled actors take their turn
		turn.value= turn + 1

	end
end
