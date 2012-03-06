require "UI"
require "generic"
require "active"
class Game
	include Generic::Base
	include Generic::Respond_To
	include Active
	attr_accessor :map, :things, :players, :views
	attr_accessor :turn
	def initialize
		@map = nil
		@players = []
		@views = []
		@controller = nil
		@things = []
		@turn = 0
		init
	end
	def init
		@map = Map.new
	end
	def start
		
	end
	def run
		while 1
			# players take their turn
			@players.each{|p| p.take_turn if p.turn == turn}
			process_events
			actors_take_turns	# all uncontrolled actors take their turn
			@turn += 1
		end
	end
	def process_events
	
	end
	def actors_take_turns
		# find actors on current turn
		turnproc = Proc.new() do |t,&y|			# Recursive actor check
			if t.class <= Actor && t.turn == turn	# Check current
				t.take_turn if t.controller.nil?
			end
			if !t.things.nil? 			# Recursion to items things
				t.things.each {|q| y.call(q,&y)}
			end
		end
		mapproc = Proc.new() do |t,&y|			# Recursive actor check
			if t.turn == turn # check current
				t.take_turn
			end
			if !t.maps.nil?					  # Recursion to submaps
				t.maps.each {|q| y.call(q,&y)}
			end
			t.things { |t| turnproc.call(t,&turnproc) }	# check the things
			# check the tiles (:tiles => tiles[:column] => tile.things)
			t.tiles.each { |ti| ti.each { |t2| t2.things.each { |t3| turnproc.call(t3,&turnproc)}}}
		end
		@things.each { |b| print(b)}
		@things.each { |t| turnproc.call(t,&turnproc) }# Find all the things in the main map
		mapproc.call(map,&mapproc)			# Find all the actors in all the maps
	end
	def stop
		@views.each {|v| v.close}
	end
end
