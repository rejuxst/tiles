require 'pry'
require "UI"
require "generic"
require "active"
require 'database'
class Game
	include Generic::Base
	include Generic::Responsive
	include Active

	add_initialize_loop do |*args|
		add_reference		"map", Map.new,	:add_then_reference => true
		add_reference_set 	"players",[],	:add_then_reference => true	
		add_reference_set 	"things",[],	:add_then_reference => true
		add_reference_set 	"views",[],	:add_then_reference => true
	end
	def start
		views.each {|v| v.setup }	
	end
	def run
		while 1
			# players take their turn
			players.each { |p| p.take_turn if p.turn == turn}
			process_events
			actors_take_turns	# all uncontrolled actors take their turn
			self.turn.value = self.turn + 1
		end
	end
	def process_events
	
	end
	def actors_take_turns
		# find actors on current turn
		turnproc = Proc.new() do |t, &y|			# Recursive actor check
			if t.is_a?(Actor) && t.turn == self.turn	# Check current
				t.take_turn if t.controller.nil?
			end
			if !t.db_empty? 			# Recursion to items things
				t.for_each_instance {|q| y.call(q,&y)}
			end
		end
		mapproc = Proc.new() do |t,&y|			# Recursive actor check
			if t.turn == turn # check current
				t.take_turn
			end
			if !t.maps.nil?					  # Recursion to submaps
				t.maps.each {|q| y.call(q,&y)}
			end
			t.for_each_instance { |t| turnproc.call(t,&turnproc) }	# check the things
			# check the tiles (:tiles => tiles[:column] => tile.things)
			t.tiles.each { |ti| ti.each { |t2| t2.for_each_instance { |t3| turnproc.call(t3,&turnproc)}}}
		end
		things.each { |b| print(b)}
		things.each { |t| turnproc.call(t,&turnproc) }# Find all the things in the main map
		mapproc.call(map,&mapproc)			# Find all the actors in all the maps
	end
	def stop
		views.each {|v| v.close}
	end
end
