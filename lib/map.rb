require "generic"
require "active"
class Map
	include Generic::Base
	include Generic::Responsive
	include Active
#	attr_reader :rows,:columns # number of rows and columns of tiles in the map
#	attr_reader :parent, :maps # list of lower level maps
#	attr_reader :tiles
	add_initialize_loop do |*args|
		add_reference_set "tiles", [] , :add_then_reference => true
		add_reference_set "maps",  [] , :add_then_reference => true
		add_variable   "columns", 20
		add_variable   "rows"	, 20

	end
#	def initialize
#		@parent = nil
#		init
#	end
	def init

	end
	# Tile access and manipulation functions 
	def tile(r,c)
		tiles[r,c]
	end
	# This function doesn't work!!! not a valid function input	
	def tile=(r,c,input)
		tiles.add([], :make_subset => r) if tiles[r].nil?
		tiles[r].add(input, :key => c)
		#@tiles[r][c] = input 
	end	
	
	def find_tile(args={},&blk)
		sol = {:tile => nil, :r => 0, :c => 0}
		rows.times do |r|
			columns.times do |c|
				if yield tile(r,c)
					sol[:tile] = tile(r,c)
					sol[:r]	= r
					sol[:c] = c
					return sol
				end
			end
		end
		return sol
	end
	#########
end
