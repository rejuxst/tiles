require 'pry'
class Game < ::Tiles::BasicObject
	include Generic::Responsive
	include Active
	add_initialize_loop do |*args|
		add_reference "map", Map.new, :add_then_reference => true
		add_reference_set "players", [], :add_then_reference => true	
		add_reference_set "things", [], :add_then_reference => true
		add_reference( "eventhandler", 
				Tiles::Application::EventHandler.new(
					:timespace => Proc.new { |f| f[Fixnum] <=> f[Fixnum] },
					:start_at  => 0
				), 
				:add_then_reference => :destroy_entry,
				:if_in_use => :destroy_entry
			)
	end

	def start; end
	def stop; end

	def run_once
		process_events
		status()
	end

	def status
		:good
	end

	def process_events
		eventhandler.execute_frame
	end

	def actors_take_turns
		# find actors on current turn
		turnproc = Proc.new() do |t, &y|			# Recursive actor check
			if t.is_a?(Actor) && t.turn == self.turn	# Check current
				t.take_turn if t.controller.nil?
			end
			if !t.db_empty? 				# Recursion to things
				t.for_each_instance {|q| y.call(q,&y)}
			end
		end
		mapproc = Proc.new() do |t,&y|			# Recursive actor check
			t.take_turn if t.turn == turn 		# check current
			t.for_each_instance { |t| turnproc.call(t,&turnproc) }	# check the things
		end
		things.each { |b| print(b)}
		things.each { |t| turnproc.call(t,&turnproc) }  # Find all the things in the main map
		mapproc.call(map,&mapproc)			# Find all the actors in all the maps
	end

end
